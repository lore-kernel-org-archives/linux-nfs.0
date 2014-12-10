Return-Path: dhowells@redhat.com
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20141210093405.23ffc328@tlielax.poochiereds.net>
References: <20141210093405.23ffc328@tlielax.poochiereds.net> <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu> <20141209080923.2708eb4f@tlielax.poochiereds.net> <4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu> <20141209095813.163ac2bb@tlielax.poochiereds.net> <20141209195530.GA27798@hardeman.nu> <20141210065240.77a23160@tlielax.poochiereds.net> <33fa16f69b18ed67e3fd595b95497941@hardeman.nu> <20141210091734.3c612514@tlielax.poochiereds.net> <cdaf61315d77361a379e3eb1d4eaac1e@hardeman.nu>
To: Jeff Layton <jeff.layton@primarydata.com>, ikent@redhat.com,
        bcodding@redhat.com
Cc: dhowells@redhat.com, David =?UTF-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 10 Dec 2014 16:03:02 +0000
Message-ID: <32108.1418227382@warthog.procyon.org.uk>
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jeff.layton@primarydata.com> wrote:

> > This thread might be interesting:
> > https://lkml.org/lkml/2014/11/24/885
> > 
> 
> Nice. I wasn't aware that Ian was working on this. I'll take a look.

I'm not sure what the current state of this is.  There was some discussion
over how best to determine which container we need to run in - and it's
complicated by the fact that the mounter may run in a different container to
the program that triggered the mount due to mountpoint propagation.

David
