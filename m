From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lockd and pg_authenticate in 2.6.10
Date: Wed, 5 Jan 2005 14:08:50 -0500
Message-ID: <20050105190849.GB13162@fieldses.org>
References: <20050105164642.GJ26856@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CmGWe-0000Pa-In
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 11:08:56 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CmGWa-0002zn-39
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 11:08:56 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050105164642.GJ26856@suse.de>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, Jan 05, 2005 at 05:46:42PM +0100, Olaf Kirch wrote:
> I remember one of the reasons why pg_authenticate was introduced
> were the problems with lockd callbacks. But in 2.6.10 I cannot see
> lockd using it at all; only the NFSv4 code does.
> Am I missing something?

pg_authenticate has only ever been used for NFSv4 callbacks.  I
submitted a series of patches that replace pg_authenticate by a more
fine-grained callback:

http://marc.theaimsgroup.com/?l=linux-nfs&m=110263135521717&w=2

which work for me, but I haven't heard anything positive or
negative from anyone else.--b.


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
