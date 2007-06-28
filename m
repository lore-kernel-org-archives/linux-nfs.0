From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Exporting Nested Directories
Date: Thu, 28 Jun 2007 12:12:35 -0400
Message-ID: <4683DDF3.8060503@RedHat.com>
References: <19d180740706271141i7592b8bcu9b0c646ab62f550f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Adam Thomas <nfs@adamthomas.us>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3wi6-0001Z8-7a
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 09:19:10 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3wi3-0005cM-8i
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 09:19:08 -0700
In-Reply-To: <19d180740706271141i7592b8bcu9b0c646ab62f550f@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net



Adam Thomas wrote:
>  
> I'm trying to export two directories on the same filesystem. The exports 
> file looks something like this: 
>  
> /raid 192.168.1.0/23(rw,sync) <http://192.168.1.0/23(rw,sync)> 
> /raid/userdir 192.168.1.0/23(rw,sync) <http://192.168.1.0/23(rw,sync)> 
>  
> When I try to do this I get a lot of unusual behavior (some clients will 
> mount, but others won't even though they are within the same IP range). 
>  
> Are there any restriction with exporting a nested directory like this? 
No...

Try using the -v mount flag to see why the mount is failing...
Also there could be something in /var/log/message that might
explain the failure...

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
