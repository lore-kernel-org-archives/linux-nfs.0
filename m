From: Ming Zhang <blackmagic02881@gmail.com>
Subject: Re: about quota implementation
Date: Mon, 12 Mar 2007 13:29:15 -0400
Message-ID: <1173720555.3889.39.camel@dhcp-107.ibrix.com>
References: <1173715909.3889.23.camel@dhcp-107.ibrix.com>
	<20070312163517.GA8690@infradead.org>
Reply-To: blackmagic02881@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQoKq-0001fy-10
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:29:24 -0700
Received: from an-out-0708.google.com ([209.85.132.241])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQoKn-0003bO-3s
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 10:29:22 -0700
Received: by an-out-0708.google.com with SMTP id d40so2505426and
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 10:29:18 -0700 (PDT)
In-Reply-To: <20070312163517.GA8690@infradead.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-03-12 at 16:35 +0000, Christoph Hellwig wrote:
> On Mon, Mar 12, 2007 at 12:11:49PM -0400, Ming Zhang wrote:
> > Hi All
> > 
> > I have a question about current quota implementation. 
> > 
> > This is current implementation. There is a rquotad running on same box
> > as nfsd. Then in quota-tools, it check if file system type is nfs, then
> > it invoke a rpc call and get that from rquotad.
> > 
> > Another way is to implement the s_qcops in kernel nfs client and thus
> > quota-tools can use a unified way to get quotactl information.
> > 
> > Any special reason why not use 2nd way to make quota-tools simpler? One
> > reason I can think of is to put unnecessary code out of kernel. Is there
> > any other reason?
> 
> I think it's mostly a historical issue.  There was no abstraction
> between the quotactl syscall and the default disk based quota implementation
> at the time the nfs quote code was written.  I'd definitively welcome
> a patch adding a kernel interface for nfs quotas.

thx. 

sys_quotactl call lookup_bdev() where return an error for device with
MNT_NODEV option. this will prevent nfs from going further. 

so why we need to judge MNT_NODEV here in lookup_bdev()? at least from
the function name, it does not say it can not/should not return a bdev
with nodev option. so this function does something it does not claim to
do. will this be a bad practice?

Ming


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
