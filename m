From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Wildcards matching ".": exports bug or just documentation bug?
Date: Wed, 13 Nov 2002 13:55:22 +0000
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <20021113135522.B3115@redhat.com>
References: <20021004125704.A8969@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Tweedie <sct@redhat.com>, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net, neilb@redhat.com,
	trond.myklebust@fys.uio.no
In-Reply-To: <20021004125704.A8969@redhat.com>; from sct@redhat.com on Fri, Oct 04, 2002 at 12:57:04PM +0100
List-ID: <nfs.lists.sourceforge.net>

Hi,

On Fri, Oct 04, 2002 at 12:57:04PM +0100, Stephen C. Tweedie wrote:
 
> mountd treats wildcards in hostnames in the exports file as matching
> anything, including ".".
> However, the exports man page explicitly states that "*" and "?" do not
> match ".":
 
> So, which is right, the actual behaviour or the documented behaviour?
> I'd tend to lean towards the former.

Ping?  This is a pretty serious discrepancy between the documented and
implemented behaviour.  The documentation *explicitly* states that

	*.com

won't match foo.bar.com, but the implentation matches this just fine.
Given that the documented behaviour doesn't actually give you a way to
match an export for all arbitrarily-deep subdomains underneath a
domain, I'd think matching subdomains of all levels with "*" makes
more sense than matching only a single level, so it's the
documentation that needs to be updated.

--Stephen
