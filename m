From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Wildcards matching ".": exports bug or just documentation bug?
Date: Thu, 14 Nov 2002 09:13:44 +1100
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <15826.52888.862126.375854@notabene.cse.unsw.edu.au>
References: <20021004125704.A8969@redhat.com>
	<20021113135522.B3115@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <sct@redhat.com>) (for <nfs@lists.sourceforge.net>)
	(for <trond.myklebust@fys.uio.no>)
	(for <linux-fsdevel@vger.kernel.org>) By tone With Smtp ;
	Thu, 14 Nov 2002 09:13:45 +1100
To: "Stephen C. Tweedie" <sct@redhat.com>
In-Reply-To: message from Stephen C. Tweedie on Wednesday November 13
List-ID: <nfs.lists.sourceforge.net>

On Wednesday November 13, sct@redhat.com wrote:
> Hi,
> 
> On Fri, Oct 04, 2002 at 12:57:04PM +0100, Stephen C. Tweedie wrote:
>  
> > mountd treats wildcards in hostnames in the exports file as matching
> > anything, including ".".
> > However, the exports man page explicitly states that "*" and "?" do not
> > match ".":
>  
> > So, which is right, the actual behaviour or the documented behaviour?
> > I'd tend to lean towards the former.
> 
> Ping?  This is a pretty serious discrepancy between the documented and
> implemented behaviour.  The documentation *explicitly* states that
> 
> 	*.com
> 
> won't match foo.bar.com, but the implentation matches this just fine.
> Given that the documented behaviour doesn't actually give you a way to
> match an export for all arbitrarily-deep subdomains underneath a
> domain, I'd think matching subdomains of all levels with "*" makes
> more sense than matching only a single level, so it's the
> documentation that needs to be updated.

Sorry for not responding the first time...

I completely agree with your analysis.

Does the following make the situation suitable clear?  If so I will
commit it.

NeilBrown


Index: utils/exportfs/exports.man
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/exportfs/exports.man,v
retrieving revision 1.9
diff -u -r1.9 exports.man
--- utils/exportfs/exports.man	17 Jan 2002 00:04:25 -0000	1.9
+++ utils/exportfs/exports.man	13 Nov 2002 22:11:58 -0000
@@ -45,9 +45,10 @@
 .IP "wildcards
 Machine names may contain the wildcard characters \fI*\fR and \fI?\fR.
 This can be used to make the \fIexports\fR file more compact; for instance,
-\fI*.cs.foo.edu\fR matches all hosts in the domain \fIcs.foo.edu\fR. However,
-these wildcard characters do not match the dots in a domain name, so the
-above pattern does not include hosts such as \fIa.b.cs.foo.edu\fR.
+\fI*.cs.foo.edu\fR matches all hosts in the domain
+\fIcs.foo.edu\fR.  As these characters also match the dots in a domain
+name, the given pattern will also match all hosts within any subdomain
+of \fIcs.foo.edu\fR.
 .IP "IP networks
 You can also export directories to all hosts on an IP (sub-) network
 simultaneously. This is done by specifying an IP address and netmask pair
