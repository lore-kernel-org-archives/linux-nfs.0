From: Paul Clements <paul.clements@steeleye.com>
Subject: Re: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Tue, 31 Aug 2004 23:49:05 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413546B1.4080306@steeleye.com>
References: <4124DB86.9060505@steeleye.com>	<16677.22269.988036.787320@cse.unsw.edu.au>	<412E1C10.5020703@steeleye.com>	<16692.8187.411591.69640@cse.unsw.edu.au>	<4134A6AD.1060502@steeleye.com> <16693.4161.921397.480506@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2M7Z-0008Bk-Bh
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 20:49:17 -0700
Received: from stat16.steeleye.com ([209.192.50.48] helo=fenric.sc.steeleye.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C2M7X-0007kH-T4
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 20:49:17 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16693.4161.921397.480506@cse.unsw.edu.au>
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

Neil Brown wrote:
> On Tuesday August 31, paul.clements@steeleye.com wrote:

> I added a bit to the documentation to describe the arguments passed to
> the callout.

Those look good to me.


> Note that for statd, I dropped the third arg being passed.  It seemed
> easier than explaining in the doco why there is a fourth arg.
> Also note that I don't remember what "my_name" is all about.  Could
> you provide a small piece of text to go there.

The my_name argument is the server name, but honestly, I don't know that 
we need anything other than the client name (we really just need to know 
what files to create in the sm/sm.bak directories) so if you want to 
just drop that argument it's fine with me.


> Finally, would you consider having "unmount" instead of "umount" as a
> possible first arg for the mountd callout?

unmount instead of umount is fine if you want to go ahead and make that 
change...

Thanks,
Paul


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
