From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Mon, 6 Sep 2004 12:17:34 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16699.51390.633644.1498@cse.unsw.edu.au>
References: <4124DB86.9060505@steeleye.com>
	<16677.22269.988036.787320@cse.unsw.edu.au>
	<412E1C10.5020703@steeleye.com>
	<16692.8187.411591.69640@cse.unsw.edu.au>
	<4134A6AD.1060502@steeleye.com>
	<16693.4161.921397.480506@cse.unsw.edu.au>
	<413546B1.4080306@steeleye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C494k-00075z-7g
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 19:17:46 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C494j-0000FO-7e
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 19:17:45 -0700
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
> Neil Brown wrote:
> > On Tuesday August 31, paul.clements@steeleye.com wrote:
> 
> > I added a bit to the documentation to describe the arguments passed to
> > the callout.
> 
> Those look good to me.
> 
> 
> > Note that for statd, I dropped the third arg being passed.  It seemed
> > easier than explaining in the doco why there is a fourth arg.
> > Also note that I don't remember what "my_name" is all about.  Could
> > you provide a small piece of text to go there.
> 
> The my_name argument is the server name, but honestly, I don't know that 
> we need anything other than the client name (we really just need to know 
> what files to create in the sm/sm.bak directories) so if you want to 
> just drop that argument it's fine with me.
> 
> 
> > Finally, would you consider having "unmount" instead of "umount" as a
> > possible first arg for the mountd callout?
> 
> unmount instead of umount is fine if you want to go ahead and make that 
> change...
> 
> Thanks,
> Paul

Ok, I have made these changes, committed them, and tags them with
nfs-utils-1-0-6-post3.

I'm not sure if I mentioned, but I change the SIGHUP handling so that
instead of doing the work in the signal handler, I set a flag and do
the work in the main look (svc_run).  This avoids some races.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
