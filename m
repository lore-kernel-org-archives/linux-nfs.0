From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Tue, 13 Jul 2004 11:17:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040713151759.GC3023@fieldses.org>
References: <40F3D483.8020507@RedHat.com> <20040713143044.GA3023@fieldses.org> <40F3FAD8.7090707@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BkP2g-0002zD-PQ
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 08:18:02 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BkP2g-0007Ik-CV
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 08:18:02 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40F3FAD8.7090707@RedHat.com>
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

On Tue, Jul 13, 2004 at 11:08:08AM -0400, Steve Dickson wrote:
> Starting up a test run, zeroing out the stats give you a very clear
> picture of what exactly is going on...

But you could exactly the same thing by recording the values at the
beginning of the test run and then subtracting.  In practice this is
likely to be annoying, so you'd want to write utilities that did this
for you, like say

checkpoint_stats stats.txt
display_stats --since stats.txt

That'd do what you want, right?

--Bruce Fields


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
