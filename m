From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: nfs-utils 1.0.3 compile error w/gcc-3.2.2
Date: Fri, 28 Mar 2003 10:13:26 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E846696.6010900@lucidpixels.com>
References: <3E844E32.4000008@lucidpixels.com> <200303281557.29049.stderr@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from lucidpixels.com ([66.45.37.187])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yvYB-0007TB-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Mar 2003 07:13:47 -0800
To: Alex Thiel <stderr@web.de>
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

CPP is in my path, is it hardcoded or something?


war@war:~$ which cpp
/vapp/bin/cpp
war@war:~$ cpp --version
cpp (GCC) 3.2.2
Copyright (C) 2002 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

war@war:~$ echo $PATH
/vapp/bin:/vapp/sbin:/appc/netscape-4.8:/appc/realplayer-8.0:/appc/j2re-1.4.1/bin:/appc/jdk-1.4.1/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin
war@war:~$



Alex Thiel wrote:

>On Friday 28 March 2003 14:29, Justin Piszcz wrote:
>  
>
>>-rw-r--r--    1 war      wheel        2.7k Mar 28 08:24 log.bz2
>>
>>The error is contained in the attachment.
>>    
>>
>
>Did you notice this in your log:
>
>Making all in export
>rm -f mount.h mount_clnt.c mount_xdr.c
>../../bin/rpcgen -h -o mount.h mount.x
>cannot find any C preprocessor (cpp)
>^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>
>Make sure cpp is in your search path.
>
>	Alex
>
>
>
>  
>




-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
