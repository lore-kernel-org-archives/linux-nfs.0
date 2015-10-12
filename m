Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46466 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752513AbbJLTZj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2015 15:25:39 -0400
Date: Mon, 12 Oct 2015 15:25:38 -0400
To: Nick Bowler <nbowler@draconx.ca>
Cc: linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
Message-ID: <20151012192538.GG28755@fieldses.org>
References: <20151012164846.GA5017@draconx.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151012164846.GA5017@draconx.ca>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 12, 2015 at 12:48:56PM -0400, Nick Bowler wrote:
> Hi,
> 
> I'm having a problem where, eventually, the nfs-mounted home directory
> on one of my machines starts failing in a kind of weird way.  The issue
> appears to affect only sqlite; I have two applications that I know of
> which use it:
> 
>   - Firefox, where the symptom is that the browser just hangs randomly,
>   - gmpc, which crashes immediately on startup with I/O error.
> 
> Once the issue occurs these applications remain permanently broken.
> Since the latter is easier to test, I can run it in strace, and the
> failing syscall seems to be:
> 
>   fcntl(7, F_SETLK, {type=F_RDLCK, whence=SEEK_SET, start=1073741824, len=1}) = -1 EIO (Input/output error)
> 
> When the issue occurs, the client dmesg log is full of messages of the form:
> 
>   [3441972.381211] NFS: v4 server returned a bad sequence-id error on an unconfirmed sequence ffff88007612ae20!
> 
> There are no unusual messages on the server.
> 
> Rebooting the client corrects the issue in the short term, but it seems
> to re-occur after about 1 month of uptime.  This makes it difficult to
> test anything.  So right now I have left the client in the broken state
> in case there's something else I can try.
> 
> The client is running Linux 4.2, with approx. 38 days uptime.  The
> server is running Linux 4.1.4, with 62 days uptime.
> 
> Let me know if you need any more info.

That does sound like a pain to debug.

I don't *think* this could be explained by the problem Jeff's seqid
locking patches fixed, but maybe I'm wrong; cc'ing him to confirm.

I wonder if there's some way to make this reproduce more quickly, for
example by running something that makes more aggressive use of sqlite,
or running multiple copies of such a thing simultaneously.  Might be
interesting to know what the pattern of file opens and locking looks
like (so stracing one of those applications might help).

--b.
