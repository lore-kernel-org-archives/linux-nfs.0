Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52989 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757946Ab2CSS5B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 14:57:01 -0400
Date: Mon, 19 Mar 2012 14:56:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Rick Macklem <rmacklem@uoguelph.ca>,
        linux-nfs@vger.kernel.org, nfsv4@ietf.org
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
Message-ID: <20120319185655.GE23670@fieldses.org>
References: <1085412836.1228438.1332175460830.JavaMail.root@erie.cs.uoguelph.ca>
 <1802632483.1230802.1332176807484.JavaMail.root@erie.cs.uoguelph.ca>
 <20120319173656.GA23670@fieldses.org>
 <126867CF-7CAA-4E3D-A9D6-2A5FE30A7DB4@oracle.com>
 <20120319182712.GB23670@fieldses.org>
 <A39DDC79-274A-427F-9887-28DD74BA56ED@oracle.com>
 <20120319183955.GC23670@fieldses.org>
 <4F678016.9050803@rath.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F678016.9050803@rath.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 19, 2012 at 02:51:02PM -0400, Nikolaus Rath wrote:
> At least in the case that sparked this discussion, it would already be
> enough to return NFS4ERR_INUSE only if the client id is being reassigned
> *and* has a 0.0.0.0 (aka autodetection failed) value.

The clientid's supposed to be totally opaque to the server, so
recognizing that case (even knowing where in the clientid to look for
the "0.0.0.0") would require the server to behave in a way that was
extremely specific to particular versions of the Linux client--something
we definitely want to avoid doing.

--b.
