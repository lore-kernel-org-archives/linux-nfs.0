From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 14:43:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <408963E0.9070001@RedHat.com>
References: <40892507.2030004@RedHat.com> <20040423143308.GW3491@suse.de> <40893B51.2080302@RedHat.com> <20040423175552.GA13755@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH5eU-0003jf-9b
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 11:43:54 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BH5eM-0002xg-DE
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 11:43:46 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040423175552.GA13755@suse.de>
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

Olaf Kirch wrote:

>On Fri, Apr 23, 2004 at 11:50:41AM -0400, Steve Dickson wrote:
>  
>
>>client: writes 100m file called foo
>>server: renames foo to foo.old and immediately creates foo
>>client: failed with ESTALE
>>    
>>
>This shouldn't fail, because the file still exists, just
>under a different name.
>  
>
This must have been cut and paste error... Because I ran the
test again and didn't see a ESTALE error...

>What will get you into trouble is if your client writes
>to "foo" and you do a "mv bar foo".
>  
>
This also seem to work... I figured since foo was open it
got renamed to .nfs file until the first write was finished...

>So what exactly went wrong? A stat() on the files that just got
>replaced?
>  
>
Yes... problem is the files get changed but the mtime on the directory
does not...

SteveD.


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
