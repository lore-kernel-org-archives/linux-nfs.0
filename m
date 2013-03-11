From: Frank S Filz <ffilz@us.ibm.com>
Subject: Re: [PATCH v3 7/7] NFSD: Pass share reservations flags to VFS
Date: Mon, 11 Mar 2013 13:37:41 -0700
Message-ID: <OFF08D878D.67DCB665-ON87257B2B.0071316C-88257B2B.00715025@us.ibm.com>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
	<1362065133-9490-8-git-send-email-piastry@etersoft.ru>
	<20130311150540.119abd63@corrin.poochiereds.net>
	<20130311193638.GB642@fieldses.org>
	<20130311160844.7dedf15a@corrin.poochiereds.net>
	<20130311201108.GE642@fieldses.org>
	<OF1D20435B.D7D7B48E-ON87257B2B.006FB8C9-88257B2B.00702F2E@us.ibm.com>
	<20130311203110.GF642@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4201645324730040375=="
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>, wine-devel@winehq.org,
	linux-kernel@vger.kernel.org, Pavel Shilovsky <piastry@etersoft.ru>,
	linux-fsdevel@vger.kernel.org, linux-nfs-owner@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <wine-devel-bounces@winehq.org>
In-Reply-To: <20130311203110.GF642@fieldses.org>
List-Unsubscribe: <http://www.winehq.org/mailman/options/wine-devel>,
	<mailto:wine-devel-request@winehq.org?subject=unsubscribe>
List-Archive: <http://www.winehq.org/pipermail/wine-devel>
List-Post: <mailto:wine-devel@winehq.org>
List-Help: <mailto:wine-devel-request@winehq.org?subject=help>
List-Subscribe: <http://www.winehq.org/mailman/listinfo/wine-devel>,
	<mailto:wine-devel-request@winehq.org?subject=subscribe>
Sender: wine-devel-bounces@winehq.org
Errors-To: wine-devel-bounces@winehq.org
List-ID: <linux-nfs.vger.kernel.org>

--===============4201645324730040375==
Content-type: multipart/alternative;
	Boundary="0__=08BBF1B8DFE2B7FC8f9e8a93df938690918c08BBF1B8DFE2B7FC"
Content-Disposition: inline

--0__=08BBF1B8DFE2B7FC8f9e8a93df938690918c08BBF1B8DFE2B7FC
Content-type: text/plain; charset=US-ASCII

"J. Bruce Fields" <bfields@fieldses.org>  wrote> >
> > Another bit to consider, does lockd provide share reservations for NLM?
>
> Yes.  I don't know if anyone's tested them in recent memory!  But it
> might be interesting to write a few simple tests for them and hook them
> up to this on the server side.  (I don't know if they'd be worth
> implementing on the client side?)

Oh, they would be REALLY NICE to have on the client side... Then we can
test NLM_SHARE with an open source client and not only with Windows...

Frank
--0__=08BBF1B8DFE2B7FC8f9e8a93df938690918c08BBF1B8DFE2B7FC
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt><font size="2">&quot;J. Bruce Fields&quot; &lt;bfields@fieldses.org&gt; &nbsp;wrote&gt; &gt; <br>
&gt; &gt; Another bit to consider, does lockd provide share reservations for NLM?<br>
&gt; <br>
&gt; Yes. &nbsp;I don't know if anyone's tested them in recent memory! &nbsp;But it<br>
&gt; might be interesting to write a few simple tests for them and hook them<br>
&gt; up to this on the server side. &nbsp;(I don't know if they'd be worth<br>
&gt; implementing on the client side?)<br>
</font></tt><br>
<tt><font size="2">Oh, they would be REALLY NICE to have on the client side... Then we can test NLM_SHARE with an open source client and not only with Windows...</font></tt><br>
<br>
<tt><font size="2">Frank</font></tt><br>
</body></html>
--0__=08BBF1B8DFE2B7FC8f9e8a93df938690918c08BBF1B8DFE2B7FC--



--===============4201645324730040375==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline



--===============4201645324730040375==--
