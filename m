Return-Path: nfsv4-bounces@ietf.org
From: Thomas Haynes <thomas.haynes@primarydata.com>
Date: Sat, 26 Apr 2014 09:35:22 -0700
Message-Id: <B05F63D2-8DB8-4FD3-92F9-C3A5B0A99D99@primarydata.com>
To: "nfsv4 list (nfsv4@ietf.org)" <nfsv4@ietf.org>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: [nfsv4] Resolving the fate of FATTR4_CHANGE_SEC_LABEL
List-Unsubscribe: <https://www.ietf.org/mailman/options/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4/>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============8684130612947522666=="
Errors-To: nfsv4-bounces@ietf.org
Sender: "nfsv4" <nfsv4-bounces@ietf.org>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============8684130612947522666==
Content-Type: multipart/alternative;
 boundary="Apple-Mail=_9CCD9C3C-9E6F-40FA-94BB-C68927898710"

--Apple-Mail=_9CCD9C3C-9E6F-40FA-94BB-C68927898710
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

In my issues file, I have:

4) Labeled NFS - FATTR4_CHANGE_SEC_LABEL - how big does it need to
   be?  Is seLinux going to support it?

   The Labeled NFS prototype in use does not currently support
   change_sec_label.

   In the past, we argued about how big it needed to be - we need
   to close down on this.

If we look at the current text in the NFSv4.2 draft, we see:

      The second change is to provide methods for the client to
      determine if the security label has changed. A client which
      needs to know if a label is going to change SHOULD request a
      delegation on that file. In order to change the security
      label, the server will have to recall all delegations. This
      will inform the client of the change. If a client wants to
      detect if the label has changed, it MAY use VERIFY and NVERIFY
      on FATTR4_CHANGE_SEC_LABEL to detect that the FATTR4_SEC_LABEL
      has been modified.

So the first question is do we need two methods for detecting that the =
label
has changed?

Section 8.3 of =
http://www.ietf.org/id/draft-ietf-nfsv4-minorversion2-21.txt covers
how the client could use delegations to detect a label change.

To quote Trond out of context:

but that is the only option I can see for implementing a cache
consistency model for labels. Without it, the choices are:

 1) always fetch the label as part of every COMPOUND.
 2) assume the label never changes on the server.

The main use cases that have been presented for Labeled NFS on Linux
would tend to push me towards door number 2, Monty please...

So a client could assume that the label never changes the majority
of the time. Once it decides it does need to start checking for a change
in the label, it can get a delegation.

If we do need the attribute, what size does it need to be?

There has been mention of it being a hash or a timestamp.=

--Apple-Mail=_9CCD9C3C-9E6F-40FA-94BB-C68927898710
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
></head><body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; -we=
bkit-line-break: after-white-space;"><div>In my issues file, I have:</div><=
div><br></div>4) Labeled NFS - FATTR4_CHANGE_SEC_LABEL - how big does it ne=
ed to<br>&nbsp; &nbsp;be?&nbsp;&nbsp;Is seLinux going to support it?<br><br=
>&nbsp; &nbsp;The Labeled NFS prototype in use does not currently support<b=
r>&nbsp; &nbsp;change_sec_label.<br><br>&nbsp; &nbsp;In the past, we argued=
 about how big it needed to be - we need<br>&nbsp; &nbsp;to close down on t=
his.<div><br></div><div>If we look at the current text in the NFSv4.2 draft=
, we see:</div><div><br></div><div>&nbsp; &nbsp; &nbsp;&nbsp;The second cha=
nge is to provide methods for the client to<br>&nbsp; &nbsp; &nbsp;&nbsp;de=
termine if the security label has changed. A client which<br>&nbsp; &nbsp; =
&nbsp;&nbsp;needs to know if a label is going to change SHOULD request a<br=
>&nbsp; &nbsp; &nbsp;&nbsp;delegation on that file. In order to change the =
security<br>&nbsp; &nbsp; &nbsp;&nbsp;label, the server will have to recall=
 all delegations. This<br>&nbsp; &nbsp; &nbsp;&nbsp;will inform the client =
of the change. If a client wants to<br>&nbsp; &nbsp; &nbsp;&nbsp;detect if =
the label has changed, it MAY use VERIFY and NVERIFY<br>&nbsp; &nbsp; &nbsp=
;&nbsp;on FATTR4_CHANGE_SEC_LABEL to detect that the FATTR4_SEC_LABEL<br>&n=
bsp; &nbsp; &nbsp;&nbsp;has been modified.<br><br></div><div>So the first q=
uestion is do we need two methods for detecting that the label</div><div>ha=
s changed?</div><div><br></div><div>Section 8.3 of&nbsp;<a href=3D"http://w=
ww.ietf.org/id/draft-ietf-nfsv4-minorversion2-21.txt">http://www.ietf.org/i=
d/draft-ietf-nfsv4-minorversion2-21.txt</a> covers</div><div>how the client=
 could use delegations to detect a label change.</div><div><br></div><div>T=
o quote Trond out of context:</div><div><br></div><blockquote style=3D"marg=
in: 0 0 0 40px; border: none; padding: 0px;"><div>but that is the&nbsp;only=
 option I can see for implementing a cache</div><div>consistency model for&=
nbsp;labels. Without it, the choices are:</div><div><br></div><div>&nbsp;1)=
 always fetch the label as part of every COMPOUND.</div><div>&nbsp;2) assum=
e the label never changes on the server.</div><div><br></div><div>The main =
use cases that have been presented for Labeled NFS on Linux</div><div>would=
 tend to push me towards door number 2, Monty please...</div></blockquote><=
div><br></div><div>So a client could assume that the label never changes th=
e majority</div><div>of the time. Once it decides it does need to start che=
cking for a change</div><div>in the label, it can get a delegation.</div><d=
iv><br></div><div>If we do need the attribute, what size does it need to be=
?</div><div><br></div><div>There has been mention of it being a hash or a t=
imestamp.</div></body></html>=

--Apple-Mail=_9CCD9C3C-9E6F-40FA-94BB-C68927898710--

--===============8684130612947522666==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

--===============8684130612947522666==--
