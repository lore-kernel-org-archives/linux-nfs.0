From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 10:42:15 +1000
Message-ID: <18095.55015.61682.405466@notabene.brown>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<18095.45961.578381.351608@notabene.brown>
	<Pine.BSO.4.64.0707311928380.5541@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IG2IB-0002Q6-6H
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 17:42:23 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IG2ID-00074g-OI
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 17:42:27 -0700
In-Reply-To: message from david m. richter on Tuesday July 31
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

On Tuesday July 31, richterd@citi.umich.edu wrote:
> > Sounds useful, though I think it would be even more useful if you
> > could specify a number of seconds rather than needing to interrupt.
> > That way you could use it in a script.
> > Maybe even get it to repeat every n seconds?
> > 
> > Thanks. I'll look through the patches.
> > 
> > NeilBrown
> 
> 	roger -- i'll look at adding an optional timeout w/ optional 
> repeat.  good idea. 
> 

Cool.  I have added everything to the git tree.
(Nicely broken up patch set by the way - very easy to review).
I made a couple of little cosmetic changes
 - removed all spaces before tabs or newlines
 - removed tabs before newlines
 - made these:
+#define DECLARE_SRV(n, s...)	static statinfo n##s[] = { \
+					SRV(net,s), \
+					SRV(rpc,s), \
+					SRV(rc,s), \
+					SRV(fh,s), \
+					SRV(proc2,s), \
+					SRV(proc3,s),\
+					SRV(proc4,s), \
+					SRV(proc4ops,s),\
+					{ NULL, 0, NULL }\

   one per line.

As well as the other bits I asked for, can I get a patch to the man
page for nfsstat too please?

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
