From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH 09/11] nfs-utils: mount: Fixed mounts
 to	multi-home servers
Date: Tue, 27 Feb 2007 13:12:00 -0500
Message-ID: <45E47470.4020002@poochiereds.net>
References: <45E2C21E.9030501@RedHat.com>
	<17891.53391.618228.526904@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HM6o3-0006BX-Sz
	for nfs@lists.sourceforge.net; Tue, 27 Feb 2007 10:12:15 -0800
Received: from ms-smtp-03.southeast.rr.com ([24.25.9.102])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HM6o4-00025l-Lw
	for nfs@lists.sourceforge.net; Tue, 27 Feb 2007 10:12:10 -0800
In-Reply-To: <17891.53391.618228.526904@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Neil Brown wrote:
> On Monday February 26, SteveD@redhat.com wrote:
>> commit 253c6b866a1ed4678c30131a41ef96821bae9d5f
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Sat Feb 24 16:08:22 2007 -0500
>>
>>     Doing a connect on UDP sockets causes the Linux network
>>     stack to reject UDP patches from multi-home server with
>>     nic on the same subnet which caused mounts to hang.
>>     
>>     Signed-off-by: Steve Dickson <steved@redhat.com>
>>
>> diff --git a/support/nfs/conn.c b/support/nfs/conn.c
>> index 89f7676..06afcc4 100644
>> --- a/support/nfs/conn.c
>> +++ b/support/nfs/conn.c
>> @@ -98,7 +98,7 @@ int get_socket(struct sockaddr_in *saddr, u_int p_prot, int resvp)
>>  			return RPC_ANYSOCK;
>>  		}
>>  	}
>> -	if (type == SOCK_STREAM || type == SOCK_DGRAM) {
>> +	if (type == SOCK_STREAM) {
> 
> You are reverting a change from commit
>    c2db41e8abb6ddc9d03a0c91c6db043fa0f85a8f
> 
> This was needed so we could find our local address to get the
> call-back address sent to the server right for NFSv4.
> 
> I think the correct thing to do here is to fix mountd so that it
> replies from the correct address.  Careful use of IP_PKTINFO makes
> this fairly easy to manage.... except that the recvfrom and sendto
> code is buried inside libc.... but if memory serves, that was fixed to
> get this right some time ago.
> 
> What OS is running on this multi-homed server??
> 
> Maybe we have to do something ghastly like disconnect the socket after
> getting the local address...  I hope not.
> 
> NeilBrown
> 

I know we saw this with Solaris servers in particular (it's been a 
while, but I think I was testing against Solaris 8). The fedora BZ is 
here if you want to see all the gory details:

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=212471

I'm thinking we will have to deal with this situation, unfortunately, so 
maybe disconnecting the socket after getting the address is the best thing?

-- Jeff


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
