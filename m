From: Dave Airlie <airlied@csn.ul.ie>
Subject: Re: Group Permissions
Date: Mon, 10 Feb 2003 03:31:46 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302100329490.21446-100000@skynet>
References: <OF38FB7D1A.A54F4E06-ON48256CC9.000FDE76-48256CC9.001013B5@ussmy>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from holly.csn.ul.ie ([136.201.105.4])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18i4fg-0006ba-00
	for <nfs@lists.sourceforge.net>; Sun, 09 Feb 2003 19:31:53 -0800
To: hadi@unionswitch.com.my
In-Reply-To: <OF38FB7D1A.A54F4E06-ON48256CC9.000FDE76-48256CC9.001013B5@ussmy>
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


Isn't really an NFS issue.. NFS doesn't have a group force that I know
off...

Try setting the top group and the sticky group bit..

find . -type d -exec "chgrp group {}" ;
find . -type d -exec "chmod g+s {}" ;

this should make all files in the dirs below end up with the group of the
directroy ..

Dave.

On Mon, 10 Feb 2003 hadi@unionswitch.com.my wrote:

> Hi there ,
>
> I have a question . I don't know how to force specific group on a NFS
> share . When users save their files / works in the share , it uses a
> random group . I want to make a default group so it doesn't change /
> randomly pick it's own group . Thanks in advance .
>
> Regards ,
>
> Nurulhadi Ellis
> IT Support Engineer
> Union Switch & Signal (M) Sdn Bhd
> 1903 - 1912 , Plaza Pengkalan , 3rd Mile , Jalan Ipoh ,
> 51100 Kuala Lumpur
> MALAYSIA
> Ph  : +6 03 4045 8055
> Fax : +6 03 4045 8970
> Email : hadi@unionswitch.com.my

-- 
David Airlie, Software Engineer
http://www.skynet.ie/~airlied / airlied@skynet.ie
pam_smb / Linux DecStation / Linux VAX / ILUG person




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
