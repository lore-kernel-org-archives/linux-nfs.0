From: Ben Woodard <woodard@redhat.com>
Subject: Re: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Thu, 15 Jul 2004 17:39:12 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1089938351.4048.3149.camel@quince.llnl.gov>
References: <40F3D483.8020507@RedHat.com>
	 <20040713143044.GA3023@fieldses.org> <40F3FAD8.7090707@RedHat.com>
	 <20040713151759.GC3023@fieldses.org> <20040713180108.GF3023@fieldses.org>
	 <40F4433A.5090708@RedHat.com>  <20040714232042.GA12551@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-j1MoR2p66JOErkig9o8b"
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>, geller2@llnl.gov
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BlGl7-0007Ex-Iq
	for nfs@lists.sourceforge.net; Thu, 15 Jul 2004 17:39:29 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BlGl6-0000ib-Th
	for nfs@lists.sourceforge.net; Thu, 15 Jul 2004 17:39:29 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040714232042.GA12551@fieldses.org>
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


--=-j1MoR2p66JOErkig9o8b
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Here is something that Even Geller, the 14 year old intern that we have
here at the lab, whipped up for our own purposes. Not everything is done
exactly the way that I would have done it but I was pretty impressed for
an afternoon's work by a 14 year old. I'm sure he will accept patches.
;-)

-ben

On Wed, 2004-07-14 at 16:20, J. Bruce Fields wrote:
> On Tue, Jul 13, 2004 at 04:16:58PM -0400, Steve Dickson wrote:
> > IMHO,  its much simpler, easier and less error prone to zero them out 
> > than to make nfsstat
> > take samples then calculate the differences...
> 
> 
> Example 1:
> 	nfsstat -z
> 	nfsstat
> Example 2:
> 	nfsstat --checkpoint foo
> 	nfsstat --since foo
> 
> Example 1 is indeed a little simpler to use, but not much.
> 
> If you really wanted an interface like that in case 1, you could do that
> by storing the checkpointed stats in some default location.
> 
> If the typical use is just logging in and collecting a few seconds of
> statistics then the easiest thing might be something like
> 
> 	nfsstat -z
> 		Collecting statistics.... Hit ^C for results
> 	^C
> 	Server rpc stats:
> 	...etc.
> 
> > I just think that a bit over nfsstat's head...
> 
> I'm not sure what you mean.  It certainly shouldn't be hard to
> implement.
> 
> > but I contend that the current nfsd/rpc stats simply aren't these type
> > of stats... these are simple activity counters that let you know what
> > (if anything) is happening... I think it would be a very difficult
> > task to try to used these counts in any long term analysis... I just
> > don't think they recored the right type of information for that....
> 
> It's not obvious to me why they couldn't be used over long periods.  But
> even if the statistics-gathering daemon isn't a good example, I don't
> see why there couldn't be other cases where more than one process might
> happen to be trying to collect statistics at the same time.
> 
> --b.
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by BEA Weblogic Workshop
> FREE Java Enterprise J2EE developer tools!
> Get your free copy of BEA WebLogic Workshop 8.1 today.
> http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--=-j1MoR2p66JOErkig9o8b
Content-Disposition: attachment; filename=nfsstat.tar.gz
Content-Type: application/x-compressed-tar; name=nfsstat.tar.gz
Content-Transfer-Encoding: base64

H4sIAIsi90AAA+2X3W7aMBTHucVPcZZlgrQF7JCPC5qq2tZNu+kLtNWUglOshiRKDLRqefcdhwTo
RddNorCu/gkpyTl2HOL8z0cSFYUMZa/xilDqUN93G5T1GWX2+rimwSj1Xc9mtM/Qb9uUNcB9zYeq
meLfzwEaNzyOeW4/O+4l/xslqfYfjzkPRzKVYdwN57fbXIPi5nqe8+z+27a73H/XZ76n/K5DvQbQ
bT7Ec7zz/f989v3HOTyQZpanGc/lfZCRBSFoiNK8LQI6AHEcnH8bwOGhsNDcFFHbFBAEUM8orThf
JDIC41MBxtHKpzw3XMYi4epUimTE7wJxYHfYahKYSzMaFgR/C7Lvl/KOqPVfjNN5txi/yhpK/7+L
/8zxq/hPbZ95yu/2qdb/Lvj4oXctEtx+MgwlDKd5zlGRj4DqjaHDodXOpsW4fRoemT8taz4WMT8+
GZyGQc5nPC84eqxBKWN11noEzB3QiQC/q8ntKptoRf+r1PofTSfZvvRv+/ZK/4yW41zqaP3vgrX+
CSZ8ECASwIQdSplDUR3jNL2dZhAOh7woQJWJMM+F5EBGKWn2pkXeK9RNqm8JlkGg9aAqBRYExpdY
YFAxrCxgA7RlQcCsMmQsWjj2EvN+GTRmkAWGKYwqfDwpR+HkBLq9KjzhslhO7PvN/R9s1P8b8Xq7
a7xY/3tr/TtlnHAxXmj97wKs3VGSszAuLkx2ZaEW6/NOYNqkyeOCbxiVDduDs/OvsGwRoI2BYKKi
hhqi5q8bgUuJnYByk5XxMjH+bFq5oBpz9XSybg62y4b+w6EUMyHvt77Gi/nfcWr99x0UPjYELpYB
Wv87YJ3/RQQXKvXWPcDVAOSYJ6SZT2obiQQh3bpWJHw4TsE8wBx+HVaXS1vn79i4ZbduRMnGqvt+
RxqNRqPRaDQajUaj0Wg0Gs1b5Rf0T9tUACgAAA==

--=-j1MoR2p66JOErkig9o8b--



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
