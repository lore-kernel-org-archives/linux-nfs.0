From: "Ozy Ali" <ozzeee@hotmail.com>
Subject: Re: (no subject)
Date: Mon, 25 Mar 2002 11:03:12
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F97tytQEVFwmiXOlJUQ00007b9b@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from f97.law4.hotmail.com ([216.33.149.97] helo=hotmail.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pSG3-0007SD-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 03:03:23 -0800
To: trond.myklebust@fys.uio.no
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

my host.deny file is empty, and i cant locate ipchain file that u talk of.  
the ip that i am attempting to install from is in the host.allow file, as i 
read it should be in a HOWTO on NFS installation.  furthermore, when i 
execute the rpcinfo -p command, it says portmapper is running on both tcp 
and udp protocols.  what am i doing wrong?  by the way...i am a linux 
newbie, so be patient with me :-)


>From: Trond Myklebust <trond.myklebust@fys.uio.no>
>To: "Ozy Ali" <ozzeee@hotmail.com>
>CC: nfs@lists.sourceforge.net
>Subject: Re: [NFS] (no subject)
>Date: 22 Mar 2002 15:45:46 +0100
>
> >>>>> " " == Ozy Ali <ozzeee@hotmail.com> writes:
>
>      > hi,
>      >    ive got a system running on redhat 6.2.  i am attempting to
>      >    get another 2 pcs connected up top it as a network.  i am
>      >    currently trying to install via nfs as i only have 1 cd in
>      >    the main pc.  i have trawled through many HOWTO's and tried
>      >    their ideas. (ie. change the file etc\exports) my problem is
>      >    no matter wot i try i always get the same message wen i boot
>      >    up the netboot.img floppy in the 2nd pc. the error reads " i
>      >    could not mount that directory from the server, mount: RPC:
>      >    port mapper failure - RPC:timed out.
>
>
>      > im going out of my minds with this as ive been at it for about
>      > 2 weeks.  any help would be greatly appreciated.
>
>
>The error message is fairly explicit: the portmapper program
>(a.k.a. "/sbin/portmap") on your server appears not to be accessible
>to this client.
>
>Is portmap not running on the server, or is there anything in
>/etc/hosts.deny or in /etc/sysconfig/ipchains for instance that might
>be blocking access to that client?
>
>Cheers,
>   Trond
>
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs


_________________________________________________________________
Chat with friends online, try MSN Messenger: http://messenger.msn.com


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
