From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: NFS mount error
Date: Wed, 08 Mar 2006 11:30:51 -0500
Message-ID: <440F06BB.1090802@citi.umich.edu>
References: <a9ed420f0603080059n65c8ee01t978a5e9f58ddcbd9@mail.gmail.com>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020306070004020209040004"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FH1Yu-0002tz-2R
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 08:30:56 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FH1Yr-0007ix-Mz
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 08:30:56 -0800
To: Vijay Chauhan <kernel.vijay@gmail.com>
In-Reply-To: <a9ed420f0603080059n65c8ee01t978a5e9f58ddcbd9@mail.gmail.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------020306070004020209040004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Vijay Chauhan wrote:
> hi,
> im doing mount/unmount in an infinte loop
> while [ "a" == "a" ];
> do
> mount -t nfs -o tcp server:/filepath /mount-point
> unmount -at nfs
> done
>  
> after some successful mount/unmount its giving error message like
>  
> RPC: can't bind to reserved port.
>  
> what does it means?
>  
> TIA,
> Vijay

there are a limited number of reserved ports on every host.  each mount 
operation takes up to 5 ports (5 sockets for contacting the server's 
portmapper, mount daemon, and so on).  when each mount is finished, it 
leaves 4 sockets in TIME_WAIT and one, to the NFS server, is ESTABLISHED.

after about 120 seconds the TIME_WAIT sockets will go away, freeing 
those ports.  but if you mount in a tight loop, you are not giving these 
sockets long enough to time out.  so all the reserved ports are used up 
with TIME_WAIT sockets.  you can see this with the "netstat" command.

if you wait a few minutes, you will find that the ports free up and you 
can do more mounts.  or you can add a "sleep" in your loop.

there has been some mitigation in later kernels.

1.  port numbers can be reused immediately in some circumstances.

2.  steve d has reduced the number of sockets used for a mount request.

3.  NFSv4 can usually skip the portmapper query.

4.  the RPC client will attempt to connect to the default port first, 
and use the portmapper only if the requested service isn't available on 
the default port.

but a tight loop like yours will still probably consume all the reserved 
ports available on a client.

--------------020306070004020209040004
Content-Type: text/x-vcard; charset=utf-8;
 name="cel.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="cel.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Charles
org:Network Appliance, Incorporated;Open Source NFS Client Development
adr:535 West William Street, Suite 3100;;Center for Information Technology Integration;Ann Arbor;MI;48103-4943;USA
email;internet:cel@citi.umich.edu
title:Member of Technical Staff
tel;work:+1 734 763 4415
tel;fax:+1 734 763 4434
tel;home:+1 734 668 1089
x-mozilla-html:FALSE
url:http://troy.citi.umich.edu/u/cel/
version:2.1
end:vcard


--------------020306070004020209040004--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
