From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Bug in NFSV3 ACCESS Procedure reply
Date: Thu, 28 Aug 2008 20:27:34 -0400
Message-ID: <20080829002734.GA20109@fieldses.org>
References: <9344d2ec0808271241x375a4d86r6cfa7c10beb905c8@mail.gmail.com> <20080828173424.GA3529@fieldses.org> <9344d2ec0808281041w15e2738ew546531398f80a312@mail.gmail.com> <20080828174917.GC3529@fieldses.org> <9344d2ec0808281052s71efeeebh81fea6805b6eef10@mail.gmail.com> <20080828185425.GA6146@fieldses.org> <9344d2ec0808281422v13ed6af9gc0f91569d52ca3be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Dilip Kumar <udilipkumar@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44816 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753194AbYH2A1f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2008 20:27:35 -0400
In-Reply-To: <9344d2ec0808281422v13ed6af9gc0f91569d52ca3be-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 28, 2008 at 02:22:35PM -0700, Dilip Kumar wrote:
> I was writing some scripts to map the Unix access modes to the access
> flags in the NFS ACCESS Reply. I have run these scripts on Linux and
> Solaris machines and the results were not the same. If I have some C
> program which opens this directory in a write mode exported by an NFS
> server it succeeds, if the server is Solaris, but fails if the server
> is Linux. If I have write access on the directory, I would expect to
> see write bit set for that directory in the ACCESS reply. Programs
> like mkdir or cd require execute and write access to complete their
> operations, but a normal open with write mode should succeed in either
> case. I was more concerned about the differences in the implementation
> of ACCESS in two different servers.

Behavior that's different from Solaris probably merits investigation,
but on its own that's not justification for making a change.

It sounds like this isn't a real problem for you, just a result you
observed in some tests, so for now I'm not inclined to worry about it
very much.  If you want to pursue it, you're welcome to make a patch
(it's probably just a matter of adjusting those accessmap arrays in
fs/nfsd/vfs.c), and you may well be correct to do so, but the patch will
need to come with a more persuasive argument.

--b.
