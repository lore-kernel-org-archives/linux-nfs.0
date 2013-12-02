From: NeilBrown <neilb@suse.de>
Subject: Re: [REVIEW][PATCH 1/3] vfs: In d_path don't call d_dname on a
	mount point
Date: Mon, 2 Dec 2013 16:43:59 +1100
Message-ID: <20131202164359.4f4f2c94@notabene.brown>
References: <20131117030653.GA7670@mail.hallyn.com>
	<20131118031932.GA17621@mail.hallyn.com>
	<52899D09.5080202@cn.fujitsu.com>
	<20131118140830.GA22075@mail.hallyn.com>
	<20131118180134.GA24156@mail.hallyn.com>
	<87k3g5gnuv.fsf@xmission.com>
	<20131126181043.GA25492@mail.hallyn.com>
	<87siui1z1g.fsf_-_@xmission.com> <8738mi1yya.fsf_-_@xmission.com>
	<20131130061525.GY10323@ZenIV.linux.org.uk>
	<20131130170226.GZ10323@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8213884120781370329=="
Cc: Aditya Kali <adityakali@google.com>, NFS <linux-nfs@vger.kernel.org>,
	Containers <containers@lists.linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>,
	Eric Dumazet <edumazet@google.com>, linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Al Viro <viro@ZenIV.linux.org.uk>,
	J.Bruce Fields <bfields@fieldses.org>
Return-path: <containers-bounces@lists.linux-foundation.org>
In-Reply-To: <20131130170226.GZ10323@ZenIV.linux.org.uk>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Sender: containers-bounces@lists.linux-foundation.org
Errors-To: containers-bounces@lists.linux-foundation.org
List-ID: <linux-nfs.vger.kernel.org>

--===============8213884120781370329==
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/sVtaMs+T9l0w.98tUaHrUR."; protocol="application/pgp-signature"

--Sig_/sVtaMs+T9l0w.98tUaHrUR.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 30 Nov 2013 17:02:26 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:


> BTW, what happens if svc_export_request() ends up with pathname filling
> almost all space left, so that qword_add(bpp, blen, pth) right after the
> call of d_path() in there overwrites the beginning of d_path() output?
> Neil?  And while we are at it, handling of overflow in there looks also
> looks fishy...

In this case the returned *blen will be negative so cache_request() in
net/sunrpc/cache.h will return -EAGAIN.
cache_read() would then go into a tight loop, trying again and again to
create the request, but it will never fit in the buffer.

I guess maybe an EINVAL might help there, plus code to skip over impossible
requests.
Maybe the following.  We'd need to double check that no ->cache_request
function can fail in a way that is worth retrying, but I doubt they would.

Any thoughts Bruce?

Thanks,
NeilBrown


diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index a72de074172d..a065f827e2a3 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -748,7 +748,7 @@ static int cache_request(struct cache_detail *detail,
=20
 	detail->cache_request(detail, crq->item, &bp, &len);
 	if (len < 0)
-		return -EAGAIN;
+		return -EINVAL;
 	return PAGE_SIZE - len;
 }
=20
@@ -788,6 +788,11 @@ static ssize_t cache_read(struct file *filp, char __us=
er *buf, size_t count,
=20
 	if (rq->len =3D=3D 0) {
 		err =3D cache_request(cd, rq);
+		if (err =3D=3D -EINVAL) {
+			spin_lock(&queue_lock);
+			list_move(&rp->q.list, &rq->q.list);
+			spin_unlock(&queue_lock);
+		}
 		if (err < 0)
 			goto out;
 		rq->len =3D err;

--Sig_/sVtaMs+T9l0w.98tUaHrUR.
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUpweHznsnt1WYoG5AQJ8aA//R8A7FpjPSLh3TiGqg6c27wJ6phhS6Z7B
9B0MMDsYiYC0h3tZmGDBdv0XrT0nEPqgC7KPUijMuvKGRGLrhCVBGTctmJxFsvaE
LNt+ki+gL2eC75qk5vvxd3rQicQy4QDaux8O5CMnmypy4D1Nebian/ZkmNv8V5ja
vHsVbbvNRCTIezTX6u7z07sSrkaQz09dR9ijNh9xMQaEG5GK3xTT/vosx+0/yofH
QBqeaxn0FdtBReE2ngSYDmCX+bqDjWv5qzC1Cs4HT1/8FYAMd+YjnOhUCECf47Un
7nOJCpj8q1zZy61uVW71Lvj6obfBcSg1oAnMsR7lj1aAoi4jDDPO9bdfaYcjb9ft
3cdkKCE31cr6lbZG2zLq7cB/OYRQoNQWp4NDbiDocLGh9v1MD2/lm3J44oNCqs6t
HGVuj7CicN1aeFhxdUc8nZy3SemtE9M/Dy+7+Om229hrBa3y9oNeFnOIMp9OA8Fd
HTe0z9LUobk3tCxlydI5CGKnFmdjaYgeXTw14VKQSnEdDcy/xra1xPgcFcVXoGIz
vskEPyZF2iArOvcgapCHpkFPBNkuqKbSiIB1SeNIKlgnSjd5TqqtefIHs1KlmGvT
sCkTrb3HBr5Ha+1JBRlWlXF5v4Yo4qFH31JCyI4+YNPzo/RG28Bbqg2hp+ZRys8l
o6TrIKOgUoE=
=Ydjl
-----END PGP SIGNATURE-----

--Sig_/sVtaMs+T9l0w.98tUaHrUR.--

--===============8213884120781370329==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============8213884120781370329==--
