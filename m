From: Bernardo Innocenti <bernie@develer.com>
Subject: Re: NFS client bug in 2.6.8-2.6.11
Date: Wed, 16 Mar 2005 03:49:48 +0100
Message-ID: <42379ECC.9060100@develer.com>
References: <20050315234415.71730.qmail@web26510.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Anders Saaby <as@cohaesio.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net
To: Neil Conway <nconway_kernel@yahoo.co.uk>
In-Reply-To: <20050315234415.71730.qmail@web26510.mail.ukl.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Neil Conway wrote:

> 766 -> 770 sounds like a "small" (ish) number of patches to check, if
> we're lucky.  Did you wade through 'em all yet?  Any smoking guns?

The RPM changelog doesn't contain anything relevant
between 766 and 770:

---CUT---
* Thu Feb 24 2005 Dave Jones <davej@redhat.com>

- Use old scheme first when probing USB. (#145273)

* Wed Feb 23 2005 Dave Jones <davej@redhat.com>

- Try as you may, there's no escape from crap SCSI hardware. (#149402)

* Mon Feb 21 2005 Dave Jones <davej@redhat.com>

- Disable some experimental USB EHCI features.

* Tue Feb 15 2005 Dave Jones <davej@redhat.com>

- Fix bio leak in md layer.
---CUT---

Perhaps the changelog is incomplete.  I don't have the
two SRPMs at hand to make a comparison.

By the way, it seems upgrading to 2.6.10-1.770_FC3 just made
the bug much harder to trigger: I've definitely seen it once
again when I had left a shell sitting in an NFS directory
overnight.  I couldn't reproduce it a second time.


> PS: oh bugger, just remembered that I also reproduced my bug with a
> 2.6.8 kernel on the server; admittedly though it was an FC2 kernel so
> who knows what extra patches it had.

You can easily find out by downloading the SRPM.  Now that
Fedora provides a public CVS, perhaps it could be used to
make such investigations directly with the cvsweb interface
without downloading and unpacking a 40MB file.

-- 
  // Bernardo Innocenti - Develer S.r.l., R&D dept.
\X/  http://www.develer.com/
