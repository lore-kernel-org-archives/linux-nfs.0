From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: usr/sbin/rpc.mountd and mountd of a build
Date: Tue, 5 Oct 2004 11:48:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041005154858.GB3835@fieldses.org>
References: <BAY14-F26idcDjoYAPN00000331@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CErZq-0005NW-5f
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 08:50:10 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CErYh-0006eS-RP
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 08:50:10 -0700
To: John Que <qwejohn@hotmail.com>
In-Reply-To: <BAY14-F26idcDjoYAPN00000331@hotmail.com>
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

On Tue, Oct 05, 2004 at 04:46:42PM +0200, John Que wrote:
> I had build the nfs-utils-1.0.6.tar.gz by standard ./configure && make
> the file rpc.mountd does not exist in the build tree; there is
> a file named mountd under /utils/mountd
> 
> I suspect they are the same file; am I right ?

Yes.

> why is it named rpc.mountd and not mountd ?
> If I'll to make install , will it copy mountd to /usr/sbin/rpc.mountd

Yes.  See the "PREFIX" variable in utils/mountd/Makefile (and its use in 
the install target in rules.mk).

--b.


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
