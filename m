From: "Flavio Leitner" <flavio.leitner@gmail.com>
Subject: Re: burst mount of NFS over tcp
Date: Wed, 16 May 2007 23:25:17 -0300
Message-ID: <c355d91b0705161925j5324ba47j52e284fec4c9d61d@mail.gmail.com>
References: <c355d91b0705150817le4e067eq35802a8d94af82a7@mail.gmail.com>
	<1179257024.6464.66.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_41789_2333459.1179368717835"
Cc: nfs@lists.sourceforge.net
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoVg5-0006Ab-TY
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 19:25:18 -0700
Received: from nz-out-0506.google.com ([64.233.162.225])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoVg7-0001Hq-DL
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 19:25:20 -0700
Received: by nz-out-0506.google.com with SMTP id i11so620876nzi
	for <nfs@lists.sourceforge.net>; Wed, 16 May 2007 19:25:18 -0700 (PDT)
In-Reply-To: <1179257024.6464.66.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

------=_Part_41789_2333459.1179368717835
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 5/15/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Tue, 2007-05-15 at 12:17 -0300, Flavio Leitner wrote:
> > (please, keep myself on CC because I'm not subscribed)
> >
> > Hi,
> >
> > In the case of several (>500) mounts running at the same time with -o tcp,
> > the number of attempts that succeed is about 300-400 because it run out
> > of priviledged port (they are busy in TIME_WAIT state).
> >
> > The priviledged port range available (~512 ports) for this can't be changed to
> > avoid more port conflicts.
> >
> > An option could be reuse these ports in TIME_WAIT state openning the socket
> > with SO_REUSEADDR socket option, but the socket is a tuple:
> > (local addr, local port, remote addr, remote port, proto) and it must be
> > different from the previous one. Well, they always are equal when you
> > mount the same NFS server, so it can't be.
> >
> > I think reducing TIME_WAIT state in kernel enabling fast recycle
> > affects other tcp
> > connections and have some extra undesireble effects.
> >
> > The solution I'm proposing is to add two new nfs parameters to specify
> > a timeout and a number of retries to mount before fails. i.e.
> >
> > # mount -o tcp,rsvretry=10,rsvtimeout=5 server:/export /mnt
> >
> > This will affect mount.nfs to try bind a reserved port 10 times with a timeout
> > of 5 seconds before give up. If not used, the default behavious is unchanged
> > (i.e. try only one time and fails).
> >
> > The code should looks like:
> > +             int bind_retry=0
> > ...
> > -               if (bindresvport(so, &laddr) < 0) {
> > +              while (bindresvport(so, &laddr) < 0) {
> > +                       if (errno == EADDRINUSE && --bind_retry > 0) {
> > +                               sleep(bind_timeout);
> > +                               continue;
> > +                       }
> >
> > The real scenario could be a huge fstab or a MDA delivering e-mails for 500
> > users with home automounted.
> >
> > I was able to mount more than 1000 NFS with success in the second scenario
> > where normally I only manage to have 200-400.
> >
> > What you think?
>
> Why not fix the 'retry' mount option to deal properly with this case? I
> can't see why running out of reserved ports really needs its own mount
> options.

Sure, you are right. What about the attached one?

Thanks!

( in case of my mailer mess with patch, I leave a copy at
http://sysclose.org/nfs-utils/nfs-utils-1.0.12-bindrsvp-retry.patch )

-- 
Flavio Leitner

------=_Part_41789_2333459.1179368717835
Content-Type: application/octet-stream;
	name=nfs-utils-1.0.12-bindrsvp-retry.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f1slhx70
Content-Disposition: attachment;
	filename="nfs-utils-1.0.12-bindrsvp-retry.patch"

Clttb3VudF0gZml4IHJldHJ5PSB0byBoYW5kbGUgbGFjayBvZiByZXNlcnZlZCBwb3J0IHNpdHVh
dGlvbgoKSW4gdGhlIGNhc2Ugb2Ygc2V2ZXJhbCAoPjUwMCkgbW91bnRzIHJ1bm5pbmcgYXQgdGhl
IHNhbWUgdGltZSAKd2l0aCAtbyB0Y3AsIHRoZSBudW1iZXIgb2YgYXR0ZW1wdHMgdGhhdCBzdWNj
ZWVkIGlzIGFib3V0IDMwMC01MDAgCmJlY2F1c2UgaXQgcnVuIG91dCBvZiBwcml2aWxlZGdlZCBw
b3J0ICh0aGV5IGFyZSBidXN5IGluIFRJTUVfV0FJVCAKc3RhdGUpLgoKVGhpcyBwYXRjaCBmaXgg
cmV0cnk9IG1vdW50IG9wdGlvbiB0byBoYW5kbGUgdGhpcyBzaXR1YXRpb24uCgpTaWduZWQtb2Zm
LWJ5OiBGbGF2aW8gTGVpdG5lciA8ZmxhdmlvLmxlaXRuZXJAZ21haWwuY29tPgoKSW5kZXg6IG5m
cy11dGlscy0xLjAuMTIvdXRpbHMvbW91bnQvbmZzbW91bnQuYwo9PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0tLSBuZnMt
dXRpbHMtMS4wLjEyLm9yaWcvdXRpbHMvbW91bnQvbmZzbW91bnQuYworKysgbmZzLXV0aWxzLTEu
MC4xMi91dGlscy9tb3VudC9uZnNtb3VudC5jCkBAIC0xMTMwLDkgKzExMzAsMTMgQEAgbm9hdXRo
X2ZsYXZvcnM6CiAJCXBlcnJvcihfKCJuZnMgc29ja2V0IikpOwogCQlnb3RvIGZhaWw7CiAJfQot
CWlmIChiaW5kcmVzdnBvcnQoZnNvY2ssIDApIDwgMCkgewotCQlwZXJyb3IoXygibmZzIGJpbmRy
ZXN2cG9ydCIpKTsKLQkJZ290byBmYWlsOworCXdoaWxlIChiaW5kcmVzdnBvcnQoZnNvY2ssIDAp
IDwgMCkgeworCQl0ID0gdGltZShOVUxMKTsKKwkJaWYgKHQgPiB0aW1lb3V0IHx8IGVycm5vICE9
IEVBRERSSU5VU0UpIHsKKwkJCXBlcnJvcihfKCJuZnMgYmluZHJlc3Zwb3J0IikpOworCQkJZ290
byBmYWlsOworCQl9CisJCXNsZWVwKDEwKTsKIAl9CiAjaWZkZWYgTkZTX01PVU5UX0RFQlVHCiAJ
cHJpbnRmKF8oInVzaW5nIHBvcnQgJWQgZm9yIG5mcyBkZWFtb25cbiIpLCBuZnNfcG1hcC0+cG1f
cG9ydCk7CkluZGV4OiBuZnMtdXRpbHMtMS4wLjEyL3N1cHBvcnQvbmZzL2Nvbm4uYwo9PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09Ci0tLSBuZnMtdXRpbHMtMS4wLjEyLm9yaWcvc3VwcG9ydC9uZnMvY29ubi5jCisrKyBuZnMt
dXRpbHMtMS4wLjEyL3N1cHBvcnQvbmZzL2Nvbm4uYwpAQCAtMTkyLDYgKzE5MiwxMiBAQCBDTElF
TlQgKm1udF9vcGVuY2xudChjbG50X2FkZHJfdCAqbW50X3NlCiAJLyogY29udGFjdCB0aGUgbW91
bnQgZGFlbW9uIHZpYSBUQ1AgKi8KIAltbnRfc2FkZHItPnNpbl9wb3J0ID0gaHRvbnMoKHVfc2hv
cnQpbW50X3BtYXAtPnBtX3BvcnQpOwogCSptc29jayA9IGdldF9zb2NrZXQobW50X3NhZGRyLCBt
bnRfcG1hcC0+cG1fcHJvdCwgVFJVRSk7CisJaWYgKCptc29jayA9PSBSUENfQU5ZU09DSyAmJgor
CQlycGNfY3JlYXRlZXJyLmNmX2Vycm9yLnJlX2Vycm5vID09IEVBRERSSU5VU0UpIHsKKwkJLyog
QnViYmxlIHVwIHRoZSBlcnJvciB0byBzZWUgaG93IGl0IHNob3VsZCBiZSBoYW5kbGVkLiAqLwor
CQlycGNfY3JlYXRlZXJyLmNmX3N0YXQgPSBSUENfVElNRURPVVQ7CisJCXJldHVybiBOVUxMOwor
CX0KIAogCXN3aXRjaCAobW50X3BtYXAtPnBtX3Byb3QpIHsKIAljYXNlIElQUFJPVE9fVURQOgo=

------=_Part_41789_2333459.1179368717835
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
------=_Part_41789_2333459.1179368717835
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

------=_Part_41789_2333459.1179368717835--
