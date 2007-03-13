From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS mount problem (2000 NFS filesystems) of linux clients
 to a solaris server
Date: Tue, 13 Mar 2007 09:11:01 -0400
Message-ID: <45F6A2E5.1040306@RedHat.com>
References: <45F004BD.1070500@biochem.mpg.de>	<EXNANE01FRaqbC8wSA10000007f@exnane01.hq.netapp.com>	<45F15018.1060804@biochem.mpg.de>
	<200703091525.15438.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net, Bernhard Busch <bbusch@biochem.mpg.de>
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HR6pd-0004Jx-DI
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 06:14:25 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HR6pb-0001Uz-7y
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 06:14:24 -0700
In-Reply-To: <200703091525.15438.olaf.kirch@oracle.com>
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

Olaf Kirch wrote:
> On Friday 09 March 2007 13:16, Bernhard Busch wrote:
>> But , if i remove the sleep command the
>>
>> nfs bindresvport: Address already in use
> 
> This is a message from the mount command, and it's really
> a problem in the RPC library. At some point, mount would
> use 2 ports per mount (one when doing pmap_getport, the
> other when talking to the server's mountd). I think the getport
> call was fixed a while ago, as it doesn't really need a privport
> at all. But for many NFS servers, a privileged port is a must
> when talking to mountd.
True... there was a bug in the glibc code that was causing
pmap port queries to use privileged ports and the entire
privileged port range was not being used... both were fixed
while back...

> 
> I think one reasonable fix for this would be to make mount
> (or the rpc library) issue a setsockopt(SOL_SOCKET, SO_REUSEADDR)
> *after* it's done with the request, and before closing the socket. That way,
> we can immediately rebind to this port, without risking confusion by having to
> mount commands bind to the same port at the same time.
I looked into doing this and it got really messy quick... Remember
SO_REUSEADDR is basically a server option used for listening
sockets... so when you use this option on the client, it works
but puts the socket in a very weird state... something just
looked wrong...

I'm of the option the true answer is, Stop using privileged ports
all together. The notion that using privileged ports give any
type of security is a bit absurd... imho... Especially now that we
have true security with the -o sec=<whatever> option...

So I'm thinking we should start allowing the actual NFS mount/traffic
to exist on any port and only keep the privileged port silliness
for mountd quires... something that could actually be done over
UDP (assuming there are no firewall issues)....

steved.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
