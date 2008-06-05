From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] re-exporting NFS-mounted dir over NFS
Date: Thu, 5 Jun 2008 14:33:16 -0400
Message-ID: <20080605183316.GB4969@fieldses.org>
References: <4846A272.8040206@infineon.com> <4846AAB3.9070005@redhat.com> <4847871A.5000206@infineon.com> <4847D257.5020406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Martin Schuster (IFKL IT OS DSM CD)" <Martin.Schuster1-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45443 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920AbYFESdT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 14:33:19 -0400
In-Reply-To: <4847D257.5020406@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 05, 2008 at 07:47:35AM -0400, Peter Staubach wrote:
> The bottom line is that 1) I don't think that the NFSv4
> implementation from NetApp is as bad as feared and 2) that
> using NFSv3 with krb5 should be as secure as NFSv4 with krb5.

That's true for the protocol itself, though depending on the threat
you're worried about, the fact that NFSv4 allows the equivalent of mount
calls to be done with krb5 security (and thus thwarts spoofing of the
replies) may be an advantage for NFSv4.

--b.

> Give either or both a shot.  I think that you will be pleasantly
> surprised.
