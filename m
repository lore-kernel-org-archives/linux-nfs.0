From: Robert Rati <Robert.Rati@motorola.com>
Subject: Re: mountd through a firewall?
Date: Thu, 20 Feb 2003 10:36:07 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E5503F7.80809@motorola.com>
References: <200302201410.h1KEAXaB002624@buggy.badula.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from motgate.mot.com ([129.188.136.100])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ltgs-00051v-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 08:36:54 -0800
Received: from pobox.mot.com (pobox.mot.com [129.188.137.100])
	by motgate.mot.com (Motorola/Motgate) with ESMTP id h1KGaqcu023068
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 09:36:52 -0700 (MST)
Received: [from il02exm02.corp.mot.com (il02exm02.corp.mot.com [10.0.100.55]) by pobox.mot.com (MOT-pobox 2.0) with ESMTP id JAA17365 for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 09:36:52 -0700 (MST)]
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <200302201410.h1KEAXaB002624@buggy.badula.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Ion Badulescu wrote:
> On Wed, 19 Feb 2003 16:56:46 -0600, Robert Rati <Robert.Rati@motorola.com> wrote:
> 
>>When I start rpc.mountd, I notice that it always registers 4 ports with 
>>portmapper.  2 TCP and 2 UDP, which corespond to two separate instances 
>>of mountd.  When I run exportfs, I see that no file systems are being 
>>exported.  If I export a file system, the only difference is exportfs 
>>shows a file system being exported.  This will obviously cause a problem 
>>if I try to specify a port for rpc.mountd to run on as both instances of 
>>mountd try to use the same port and the tcp bind for the second instance 
>>fails.  Why does rpc.mountd start two instances of mountd?
> 
> 
> It doesn't, so you must be doing something very wrong on your system -- 
> are you starting a second mountd or something?

Thanks for the reply.

Actually, I mispoke in my first statement, sorry.  mountd isn't creating 
two instances on the system, but it's opening 4 ports from the same 
instance.  I thought that maybe mountd was opening a pair of ports for 
each exported filesystem, but my /etc/exports is bare, exportfs shows no 
exported file systems, so why is mountd using 4 ports?  Even if I share 
a directory, mountd is still using 4 ports.

Is there a way to control the port range mountd will use?  If not, do 
you know the range mountd will use?

Rob



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
