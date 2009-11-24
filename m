From: Neil Brown <neilb@suse.de>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Wed, 25 Nov 2009 09:22:27 +1100
Message-ID: <20091125092227.77735d5a@notabene.brown>
References: <19211.7054.291514.185591@notabene.brown>
	<4B0BEDDB.1010203@RedHat.com>
	<20091124205616.GB29856@fieldses.org>
	<20091125085122.316f4eb3@notabene.brown>
	<4B0C5705.6030608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:39167 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932789AbZKXWU1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 17:20:27 -0500
In-Reply-To: <4B0C5705.6030608@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Nov 2009 16:58:29 -0500
Peter Staubach <staubach@redhat.com> wrote:

> I think that we might be better off in the long run by taking a
> step back and getting all of the plumbing right, instead of
> cluttering up things to have knowledge which they have no
> business knowing or worrying about.

In principle, I completely agree.


> 
> If the NFSv4 server gets a request which involves the root file
> handle and one has not been defined, then it should return the
> error that is defined by the protocol.  What the client chooses
> to do with the error is up to it.

There is no error for "root file handle has not been defined".

The only errors available for PUTROOTFH are:
 NFS4ERR_RESOURCE - which means "I'm exchausted after all the other
                    work you made me do" and shouldn't be returned for
                    the first op in a compound (that is an implied
                    restriction, not explicit).
 NFS4ERR_SERVERFAULT which means something strange went wrong.  This is
                    probably the closest, hence Bruce's recent patch to
                    use this error code.
 NFS4ERR_WRONGSEC   which means the security mechanism used by the
                    client isn't acceptable to the server.  This is
                    certainly not usable in this context.

So NFS4ERR_SERVERFAULT would be OK simply because it is a wildcard.
But RPC_PROG_MISMATCH, which means "I don't support that version of the
protocol" would also be correct in this case and it trivial for the
client to interpret.

NeilBrown

