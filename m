From: "Russ Fink" <russfink@hotmail.com>
Subject: mount(2) returns EINVAL - programming prob
Date: Sat, 16 Mar 2002 09:21:41 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F1030nmR1sjVfuscsEK00000f79@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Received: from f103.law3.hotmail.com ([209.185.241.103] helo=hotmail.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16mF4C-0006xP-00
	for <nfs@lists.sourceforge.net>; Sat, 16 Mar 2002 06:21:52 -0800
To: nfs@lists.sourceforge.net
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

Hello,

I am using the UNIX mount(2) system call, and it's returning EINVAL.

If this isn't the proper forum for this question, could somebody kindly 
redirect me?  Thanks, now for the problem.

I have a piece of code that I inherited (similar to inheriting 24 cats from 
late Aunt Hildebrandt) and is using the mount system call.

For some reason, it is returning the perror "mount: Invalid argument".  I 
inserted some fprintf's and found that the error value is EINVAL.

The man page for mount (mount(2)) says that EINVAL can be caused by a lot of 
conditions - it seems to be a glorious catch-all error code, same as when 
your "brake" light goes on in your car (meaning, for example, that one of 
the 24 cats crawled into your air intake).

Has anyone had experience with mount(2), and/or resolving or chasing a 
EINVAL problem?  If so, and you need more details, I can provide them and/or 
repost.  Hopefully there's some simple way other than instrumenting the 
source to mount() or running under the debugger to figure it out.

[Does anyone even know what library mount(2) resides in?]

Thanks,
Russ Fink

[The 24 cat example was purely hypothetical.  It was actually only 23. :-]


_________________________________________________________________
Get your FREE download of MSN Explorer at http://explorer.msn.com/intl.asp.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
