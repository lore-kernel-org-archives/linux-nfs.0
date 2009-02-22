From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Sat, 21 Feb 2009 23:05:24 -0800
Message-ID: <49A0F934.8070306@candelatech.com>
References: <4977C580.4040805@candelatech.com> <633CA802-DD5A-4082-B771-C524D367241F@oracle.com> <497805A7.4070205@candelatech.com> <A1D6FF17-95D6-4775-AF60-5D6CD2078B3E@oracle.com> <4978AD75.9090900@candelatech.com> <65D69956-DB67-43A7-9101-9AFB7EC55A9F@oracle.com> <499FB08B.1070200@candelatech.com> <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030409070906000307040806"
Cc: linux-nfs@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41718 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbZBVHFf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Feb 2009 02:05:35 -0500
In-Reply-To: <EF45429F-0B16-47C7-89ED-7C14C44E6E5E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030409070906000307040806
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Chuck Lever wrote:
> Hi Ben-
>
> On Feb 21, 2009, at Feb 21, 2009, 2:43 AM, Ben Greear wrote:
>> I re-worked the kernel nfs local-address-binding logic against 
>> 2.6.29-rc5.  In quick testing,
>> this works with IPv4 and NFSv3 at least.  I changed the attribute to 
>> be called 'bindaddr'
>> as previously suggested.
>>
>> I didn't actually make any further changes to the mount.nfs tool and 
>> it took the bindaddr=a.b.c.d
>> just fine, so maybe there are no changes at all needed in user-space.
>
> You probably want the code in support/nfs/getport.c to send requests 
> from your bindaddr, if the mount command has to contact the server to 
> renegotiate mount options.
>
>> Comments & suggestions welcome.
>>
>> Thanks,
>> Ben
>>
>> Signed-Off-By:  Ben Greear<greearb@candelatech.com>
>>
>> -- 
>> Ben Greear <greearb@candelatech.com> Candela Technologies Inc  
>> http://www.candelatech.com
>>
>>
>> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
>> index 3e634f2..1c7011e 100644
>> --- a/fs/nfs/callback.c
>> +++ b/fs/nfs/callback.c
>> @@ -213,7 +213,7 @@ static int nfs_callback_authenticate(struct 
>> svc_rqst *rqstp)
>>     int ret = SVC_OK;
>>
>>     /* Don't talk to strangers */
>> -    clp = nfs_find_client(svc_addr(rqstp), 4);
>> +    clp = nfs_find_client(svc_daddr(rqstp), svc_addr(rqstp), 4);
>
> It's not clear to me why the callback server needs to be aware of the 
> mount point's bind address.  Can you explain this a little more?  I 
> would think the bind address would be pertinent for sending callback 
> service replies, but I don't see code here to do that.
>
> Would lockd also need to have this information too (passed in via 
> nlmclnt_inet)?
>
> Would we also want kernel rpcbind requests to be sensitive to the 
> passed-in bind address?

The attached patch (on top of my other patch) is my attempt at making 
lockd aware.

I tried running:

cd [my nfs mount directory]
touch foo
flock -x foo -c "echo hello"

while sniffing the interface it should be bound to, and I see what I 
believe is proper output (just the flock part):

300.647123 192.168.1.185 -> 192.168.1.5  NFS V3 GETATTR Call, FH:0x34b21b2e
300.647460  192.168.1.5 -> 192.168.1.185 NFS V3 GETATTR Reply (Call In 
133)  Regular File mode:0644 uid:0 gid:0
300.647650 192.168.1.185 -> 192.168.1.5  TCP 689 > 2049 [ACK] Seq=5409 
Ack=9565 Win=34560 Len=0
300.647846 192.168.1.185 -> 192.168.1.5  NFS V3 ACCESS Call, FH:0x34b21b2e
300.648046  192.168.1.5 -> 192.168.1.185 NFS V3 ACCESS Reply (Call In 136)
300.648267 192.168.1.185 -> 192.168.1.5  NLM V4 LOCK Call FH:0x34b21b2e 
svid:3 pos:0-0
300.648491  192.168.1.5 -> 192.168.1.185 NLM V4 LOCK Reply (Call In 138)
300.648540 192.168.1.185 -> 192.168.1.5  TCP 839 > 38489 [ACK] Seq=633 
Ack=121 Win=5888 Len=0
300.657602 192.168.1.185 -> 192.168.1.5  NLM V4 UNLOCK Call 
FH:0x34b21b2e svid:3 pos:0-0
300.657894  192.168.1.5 -> 192.168.1.185 NLM V4 UNLOCK Reply (Call In 141)
300.687712 192.168.1.185 -> 192.168.1.5  TCP 689 > 2049 [ACK] Seq=5545 
Ack=9689 Win=34560 Len=0
300.697678 192.168.1.185 -> 192.168.1.5  TCP 839 > 38489 [ACK] Seq=833 
Ack=161 Win=5888 Len=0

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com



--------------030409070906000307040806
Content-Type: text/x-patch;
 name="lockd_bind.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lockd_bind.patch"

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 1f3b0fc..d826c9c 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -59,7 +59,8 @@ struct nlm_host *nlmclnt_init(const struct nlmclnt_initdata *nlm_init)
 	if (status < 0)
 		return ERR_PTR(status);
 
-	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->addrlen,
+	host = nlmclnt_lookup_host(nlm_init->address, nlm_init->bindaddr,
+				   nlm_init->addrlen,
 				   nlm_init->protocol, nlm_version,
 				   nlm_init->hostname, nlm_init->noresvport);
 	if (host == NULL) {
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 99d737b..dc8f067 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -244,15 +244,13 @@ nlm_destroy_host(struct nlm_host *host)
  * created and returned.
  */
 struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
+				     const struct sockaddr* bindaddr,
 				     const size_t salen,
 				     const unsigned short protocol,
 				     const u32 version,
 				     const char *hostname,
 				     int noresvport)
 {
-	const struct sockaddr source = {
-		.sa_family	= AF_UNSPEC,
-	};
 	struct nlm_lookup_host_info ni = {
 		.server		= 0,
 		.sap		= sap,
@@ -261,8 +259,8 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		.version	= version,
 		.hostname	= hostname,
 		.hostname_len	= strlen(hostname),
-		.src_sap	= &source,
-		.src_len	= sizeof(source),
+		.src_sap	= bindaddr,
+		.src_len	= salen,
 		.noresvport	= noresvport,
 	};
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 6cd8bd5..7022868 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -551,6 +551,7 @@ static int nfs_start_lockd(struct nfs_server *server)
 	struct nlmclnt_initdata nlm_init = {
 		.hostname	= clp->cl_hostname,
 		.address	= (struct sockaddr *)&clp->cl_addr,
+		.bindaddr	= (struct sockaddr*)&clp->bindaddr,
 		.addrlen	= clp->cl_addrlen,
 		.protocol	= server->flags & NFS_MOUNT_TCP ?
 						IPPROTO_TCP : IPPROTO_UDP,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 330d10f..f790f4d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -45,7 +45,6 @@ struct nfs_parsed_mount_data {
 	struct {
 		struct sockaddr_storage	address;
 		size_t			addrlen;
-		char			*hostname;
 	} bindaddr;
 
 	struct {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 90f29bd..bcfb70a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1268,8 +1268,6 @@ static int nfs_parse_mount_options(char *raw,
 			nfs_parse_ip_address(string, strlen(string),
 					     (struct sockaddr *)&mnt->bindaddr.address,
 					     &mnt->bindaddr.addrlen);
-			kfree(mnt->bindaddr.hostname);
-			mnt->bindaddr.hostname = string;
 			break;
 		case Opt_mounthost:
 			string = match_strdup(args);
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index fbc48f8..c1a4b6b 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -38,6 +38,7 @@ extern struct nlmsvc_binding *	nlmsvc_ops;
 struct nlmclnt_initdata {
 	const char		*hostname;
 	const struct sockaddr	*address;
+	const struct sockaddr *bindaddr;
 	size_t			addrlen;
 	unsigned short		protocol;
 	u32			nfs_version;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index aa6fe70..0a06833 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -217,6 +217,7 @@ void		  nlmclnt_next_cookie(struct nlm_cookie *);
  * Host cache
  */
 struct nlm_host  *nlmclnt_lookup_host(const struct sockaddr *sap,
+				      const struct sockaddr* bindaddr,
 					const size_t salen,
 					const unsigned short protocol,
 					const u32 version,

--------------030409070906000307040806--
