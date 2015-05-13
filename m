Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:34016 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753298AbbEMUzl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 May 2015 16:55:41 -0400
Date: Wed, 13 May 2015 13:55:31 -0700
From: Jeremy Allison <jra@samba.org>
To: Andreas =?iso-8859-1?Q?Gr=FCnbacher?=
	<andreas.gruenbacher@gmail.com>
Cc: Jeremy Allison <jra@samba.org>, Frank Filz <ffilzlnx@mindspring.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
Message-ID: <20150513205531.GG10059@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
 <0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>
 <CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
 <20150513202803.GD10059@samba2>
 <CAHpGcMLg2+SrMJrFe9Sj-tfXVMW040xJMq2uRcAM+LBEUmqpvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <CAHpGcMLg2+SrMJrFe9Sj-tfXVMW040xJMq2uRcAM+LBEUmqpvA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 13, 2015 at 10:47:44PM +0200, Andreas Grünbacher wrote:
> 2015-05-13 22:28 GMT+02:00 Jeremy Allison <jra@samba.org>:
> > On Wed, May 13, 2015 at 10:22:21PM +0200, Andreas Grünbacher wrote:
> >>
> >> That being said, a daemon like Samba can "fake" full Automatic
> >> Inheritance by creating files and then updating the inherited acls
> >> appropriately. This will inevitably be racy, but unless someone
> >> implements a way to create files without a mode, that's the closest
> >> Samba can get.
> >
> > On Windows systems the client fake (no quotes :-) full Automatic
> > Inheritance by creating files and then updating the inherited acls
> > appropriately.
> 
> Hmm, interesting, are you *absolutely* sure about that? Is there
> anywhere I can look that up?

Hmm. Just realized we may be talking about different things :-).

In SMB/Samba the clients can create a file with no ACL, and
the directory ACL is auto inherited. *That* we fake in
Samba by creating then updating.

But in Windows there are the concept of "inherited" ACE
entries, which can come from parents of parents of parents
(etc.) objects. When a client modifies one of these on an
upper level directory, the server doesn't do the auto
updating that the vision of the file system might lead
you to expect - that updating is done by a tree walk
by the client.
