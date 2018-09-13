Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37992 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726824AbeINBM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Sep 2018 21:12:28 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87lg854ws2.fsf@suse.com>
References: <87lg854ws2.fsf@suse.com> <17451.1536750676@warthog.procyon.org.uk>
To: =?us-ascii?Q?=3D=3Futf-8=3FQ=3FAur=3DC3=3DA9lien=3F=3D?= Aptel
        <aaptel@suse.com>
Cc: dhowells@redhat.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, sfrench@samba.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-fsdevel@vger.kernel.org
Subject: Re: Making the in-kernel DNS resolver handle server lists
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Date: Thu, 13 Sep 2018 21:01:26 +0100
Message-ID: <5805.1536868886@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Aurélien Aptel <aaptel@suse.com> wrote:

> > 	struct address {
> > 		union {
> > 			struct sockaddr_in	sin;
> > 			struct sockaddr_in6	sin6;
> > 		};
> > 	};
> 
> You probably want struct sockaddr_storage here.

It's actually now:

	struct address {
		u8 family;
		union {
			struct sockaddr_in	sin;
			struct sockaddr_in6	sin6;
		};
	};

And note that this is schematic not actual.  It's not actually a C union.
ipv4 and ipv6 addresses take up different amounts of space in the binary blob.

One of the criteria is that the blob should be as small as possible since it
gets cached by the kernel as is (as the payload of a key) and only gets looked
at when it gets parsed.

David
