Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:36094 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab3ARXBH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 18:01:07 -0500
Message-ID: <50F9D431.5040600@candelatech.com>
Date: Fri, 18 Jan 2013 15:01:05 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question on nfs40_discover_server_trunking.
References: <50F9BE66.6080608@candelatech.com> <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com> <50F9C5B4.5020000@candelatech.com> <1A56CC87-38FF-47B4-9CA9-7BAE394AF0D2@oracle.com> <50F9CDDF.4070609@candelatech.com> <D275BA48-F082-424C-9DC6-A7ABAF6A4578@oracle.com> <50F9D1E7.4080203@candelatech.com>
In-Reply-To: <50F9D1E7.4080203@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Is this OK, or is the NULL assignment just not acceptable?  Due to the
complexity of this code, I think it is a good idea to initialize
the variable...



[greearb@fs3 nfs]$ git diff
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index d6b39a9..cdc99bd 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -185,7 +185,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
                                     rpc_authflavor_t authflavour)
  {
         char buf[INET6_ADDRSTRLEN + 1];
-       struct nfs_client *old;
+       struct nfs_client *old = NULL;
         int error;

         if (clp->cl_cons_state == NFS_CS_READY) {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c351e6b..7103617 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -139,6 +139,8 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
         switch (status) {
         case -NFS4ERR_STALE_CLIENTID:
                 set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+               nfs4_schedule_state_renewal(clp);
+               break;
         case 0:
                 /* Sustain the lease, even if it's empty.  If the clientid4
                  * goes stale it's of no use for trunking discovery. */
[greearb@fs3 nfs]$


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

