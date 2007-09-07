From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [BUG] 2.6.23-rc5 kernel BUG at fs/nfs/nfs4xdr.c:945
Date: Fri, 7 Sep 2007 11:29:13 -0400
Message-ID: <20070907152913.GF24638@fieldses.org>
References: <46E121B8.4080105@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, Trond Myklebust <trond@netapp.com>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITfll-0007xa-9a
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 08:29:18 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ITflo-0001XS-Ko
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 08:29:22 -0700
In-Reply-To: <46E121B8.4080105@linux.vnet.ibm.com>
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

On Fri, Sep 07, 2007 at 03:32:32PM +0530, Kamalesh Babulal wrote:
> Sep  7 11:42:49 p55lp2 kernel: kernel BUG at fs/nfs/nfs4xdr.c:945!

That's the first line of encode_lookup:

	static int encode_lookup(struct xdr_stream *xdr, const struct qstr *name)
	{
		int len = name->len;
		__be32 *p;

		RESERVE_SPACE(8 + len);

So len is either very large, or it's just garbage.  Do you know if
fsstress is trying to do something with a particularly long filename
here?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
