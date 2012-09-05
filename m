Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53976 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759091Ab2IER1D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 13:27:03 -0400
Date: Wed, 5 Sep 2012 13:27:01 -0400
To: Attila =?utf-8?B?Qm9nw6Fy?= <attila.bogar@linguamatics.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS client: RPCSEC_GSS w/ Kerberos over TCP
Message-ID: <20120905172701.GB9002@fieldses.org>
References: <5047676E.3050000@linguamatics.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5047676E.3050000@linguamatics.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 05, 2012 at 03:53:34PM +0100, Attila Bogár wrote:
> Hi,
> 
> I'm new on this list, this is my first post.
> 
> I can see some interoperability problems between FreeBSD 8 and 9
> stable NFS servers and some Linux NFS clients when using Kerberized
> NFS.
> 
> I noticed that around nfs-utils 1.2.3 something must have changed on
> the Linux side or the Linux became more agile to trigger a bug with
> the FreeBSD.
> 
> Maybe these issues have been reported or fixed, but on a current
> RHEL 6.3 and Ubuntu 12.04 LTS they still do exist.
> 
> When the Linux clients mount a FreeBSD NFS share (v3 or v4)
> sec=krb5*, they sometimes get an access denied.
> If they are able to mount anyway, then subsequent NFS I/O errors continue.
> 
> So far:
> http://lists.freebsd.org/pipermail/freebsd-fs/2012-August/015047.html
> http://lists.freebsd.org/pipermail/freebsd-fs/2012-September/015050.html
> 
> I have some questions.  As this is an interop problem, I'd like to
> clarify a few things.
> 
> This what I see on the wireshark trace during an NFSv4 mount -o
> proto=tcp,sec=krb5:
> The client is EL6 with a patched nfs-utils package as per:
> https://bugzilla.redhat.com/show_bug.cgi?id=802469 and gssd started
> with -l (legacy) option
> 
> TCP0: -> Linux NFS AUTH_NULL
> TCP0: <- FreeBSD responds
> 
> TCP1: -> Linux sends RPCSEC_GSS_INIT
> TCP1: <- FreeBSD responds by establishing GSS Context (it's a 16 byte token)
> 
> TCP1: -> Linux sends RPCSEC_GSS_DESTROY using the received 16 byte token
> TCP0: -> Linux sends NFS:PUTROOTFS|GETATTR using the same 16 byte received gss context token
> 
> 
> Re-using the gss context on the other tcp connection and immediately
> destroying it looks like a bug in the Linux NFS layer?

Yes.

Might be worth either reporting to redhat or retesting with the most
recent upstream kernel.

> Another worry I see, is that the RPCSEC_GSS_DESTROY when validated
> on the FreeBSD side gss_verify_mic returns maj_stat =
> GSS_S_DEFECTIVE_TOKEN - which is quite strange (this still can be a
> FreeBSD bug).

Right, we'd have to look closer to be sure.  Might be worth grepping the
freebsd code for returns of GSS_S_DEFECTIVE_TOKEN and seeing if that
helps pin down what its complaint is.

--b.
