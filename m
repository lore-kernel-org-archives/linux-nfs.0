From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Wed, 1 Sep 2004 09:56:49 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16693.4161.921397.480506@cse.unsw.edu.au>
References: <4124DB86.9060505@steeleye.com>
	<16677.22269.988036.787320@cse.unsw.edu.au>
	<412E1C10.5020703@steeleye.com>
	<16692.8187.411591.69640@cse.unsw.edu.au>
	<4134A6AD.1060502@steeleye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2IUo-0008Qa-2t
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 16:57:02 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C2IUl-0002Xf-Ap
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 16:56:59 -0700
To: Paul Clements <paul.clements@steeleye.com>
In-Reply-To: message from Paul Clements on Tuesday August 31
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

On Tuesday August 31, paul.clements@steeleye.com wrote:
> 
> New patch attached.
> 

Thanks.  I'm almost ready to commit it.

I added a bit to the documentation to describe the arguments passed to
the callout.

For mountd

+).
+The program will be called with 4 arguments.
+The first will be
+.B mount
+or
+.B umount
+depending on the reason for the callout.
+The second will be the name of the client performing the mount.
+The third will be the path that the client is mounting.
+The last is the number of concurrent mounts that we believe the client
+has of that path.


For statd

+The program will be run with 3 arguments:  The first is either
+.B add-client
+or
+.B del-client
+depending on the reason for the callout.
+The second will be the name of the client.
+The third will be ....
+.TP


Note that for statd, I dropped the third arg being passed.  It seemed
easier than explaining in the doco why there is a fourth arg.
Also note that I don't remember what "my_name" is all about.  Could
you provide a small piece of text to go there.

Finally, would you consider having "unmount" instead of "umount" as a
possible first arg for the mountd callout?

Thanks
NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
