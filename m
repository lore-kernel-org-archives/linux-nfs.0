From: Neil Brown <neilb@suse.de>
Subject: Re: stdio and nfs-utils
Date: Thu, 26 Jul 2007 12:59:09 +1000
Message-ID: <18088.3581.647761.879253@notabene.brown>
References: <20070725223723.GH7943@fieldses.org>
	<20070726000700.GK7943@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDtZU-00089F-2k
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 19:59:24 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDtZX-0006ME-N9
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 19:59:28 -0700
In-Reply-To: message from J. Bruce Fields on Wednesday July 25
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

On Wednesday July 25, bfields@fieldses.org wrote:
> On Wed, Jul 25, 2007 at 06:37:23PM -0400, J. Bruce Fields wrote:
> > I assume what's happening is that the stdio code is taking the error
> > returns as a sign that it should leave the data in its buffer and just
> > try again next time another fwrite adds more.  Does that make sense?
> > I don't really understand how stdio is supposed to handle errors.
> 
> So I tried a test program that just does
> 
> 	while (1) {
> 		fprintf(f, "%d\n", i++)
> 		fflush(f);
> 	}
> 
> and pointed it at one of those proc files, which will always return an
> error on such a write.  On my fedora rawhide system, each write only
> writes the new data.  On my debian sid system, each write writes all the
> data accumulated so far.  Huh.

:-)

While I can see the value it avoiding the stdio code, I can also see
some in hanging on to it, so I would first like to see if we can make
the current code work with just minor modifications.

Could you check how calling 'clearerr' interacts with this code on the
two different systems?

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
