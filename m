Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35431 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181AbbJMDCF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Oct 2015 23:02:05 -0400
Received: by iofl186 with SMTP id l186so7556205iof.2
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2015 20:02:03 -0700 (PDT)
Date: Mon, 12 Oct 2015 23:01:36 -0400
From: Nick Bowler <nbowler@draconx.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: Re: PROBLEM: nfs I/O errors with sqlite applications
Message-ID: <20151013030136.GA7081@draconx.ca>
References: <20151012164846.GA5017@draconx.ca>
 <20151012192538.GG28755@fieldses.org>
 <20151012194647.GJ28755@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/9DWx/yDrRhgMJTb"
In-Reply-To: <20151012194647.GJ28755@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 2015-10-12 15:46 -0400, J. Bruce Fields wrote:
> On Mon, Oct 12, 2015 at 03:25:38PM -0400, bfields wrote:
> > On Mon, Oct 12, 2015 at 12:48:56PM -0400, Nick Bowler wrote:
> > > I'm having a problem where, eventually, the nfs-mounted home directory
> > > on one of my machines starts failing in a kind of weird way.  The issue
> > > appears to affect only sqlite; I have two applications that I know of
> > > which use it:
> > > 
> > >   - Firefox, where the symptom is that the browser just hangs randomly,
> > >   - gmpc, which crashes immediately on startup with I/O error.
> > > 
> > > Once the issue occurs these applications remain permanently broken.
> > > Since the latter is easier to test, I can run it in strace, and the
> > > failing syscall seems to be:
> > > 
> > >   fcntl(7, F_SETLK, {type=F_RDLCK, whence=SEEK_SET, start=1073741824, len=1}) = -1 EIO (Input/output error)
> > > 
> > > When the issue occurs, the client dmesg log is full of messages of the form:
> > > 
> > >   [3441972.381211] NFS: v4 server returned a bad sequence-id error on an unconfirmed sequence ffff88007612ae20!
> > > 
> > > There are no unusual messages on the server.
[...]
> > I wonder if there's some way to make this reproduce more quickly, for
> > example by running something that makes more aggressive use of sqlite,
> > or running multiple copies of such a thing simultaneously.  Might be
> > interesting to know what the pattern of file opens and locking looks
> > like (so stracing one of those applications might help).

I could try doing something like using the sqlite3 command-line tool to
do a lot of database operations, and hope I can reproduce.  I'd have to
reboot to test though.

I attached a full strace log (gzipped) from a failing process.  The
command run is:

  sqlite3 newfile.sqlite vacuum

which fails in a similar manner to gmpc.

> Oh, also I forgot to ask what version of the NFS protocol you're using
> (4.0, 4.1, or 4.2).

Looks like 4.0:

  athena:/home on /home type nfs4 (rw,relatime,vers=4.0,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=krb5,clientaddr=192.168.0.207,local_lock=none,addr=192.168.0.10)

Cheers,
  Nick

--/9DWx/yDrRhgMJTb
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="sqlite3-vacuum-strace.log.gz"
Content-Transfer-Encoding: base64

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
vyvn5+eSoGe29OyEjxIEEh+q/ANm4INtazYAAA==

--/9DWx/yDrRhgMJTb--
