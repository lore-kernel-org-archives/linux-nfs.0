Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33604 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751916AbbG3Pif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 11:38:35 -0400
Date: Thu, 30 Jul 2015 11:38:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        tigran.mkrtchyan@desy.de
Subject: Re: [PATCH v2] 4.0 setclientid: More cases for setclientid behavior
Message-ID: <20150730153834.GH9349@fieldses.org>
References: <55B76B94.4060208@gmail.com>
 <20150729190738.GA21742@fieldses.org>
 <55B9EBE4.9040303@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55B9EBE4.9040303@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 30, 2015 at 05:18:28PM +0800, Kinglong Mee wrote:
> More cases of RFC 7530 16.33.5 setclientid/setclientid_confirm behavior.
> 
> v2, As Bruce said,
> 
> "I'd rather not change the test code from CID2 to CID4a. That kind of
>  change makes it hard to compare results across different versions of
>  pynfs."

OK, thanks.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  nfs4.0/servertests/st_setclientid.py | 217 ++++++++++++++++++++++++++++++++++-
>  1 file changed, 213 insertions(+), 4 deletions(-)
> 
> diff --git a/nfs4.0/servertests/st_setclientid.py b/nfs4.0/servertests/st_setclientid.py
> index e9d0052..ca795f7 100644
> --- a/nfs4.0/servertests/st_setclientid.py
> +++ b/nfs4.0/servertests/st_setclientid.py
> @@ -61,10 +61,9 @@ def testInUse(t, env):
>      """
>      c1 = env.c1
>      c2 = env.c2
> -    c1.init_connection("Badid_for_%s_pid=%i" % (t.code, os.getpid()),
> -                       verifier=c1.verifier)
> -    ops = [c2.setclientid(id="Badid_for_%s_pid=%i" % (t.code, os.getpid()),
> -                          verifier=c1.verifier)]
> +    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
> +    c1.init_connection(clid, verifier=c1.verifier)
> +    ops = [c2.setclientid(clid, verifier=c1.verifier)]
>      res = c2.compound(ops)
>      check(res, NFS4ERR_CLID_INUSE, "SETCLIENTID with same nfs_client_id.id")
>      
> @@ -115,6 +114,216 @@ def testAllCases(t, env):
>      res = c.compound([c.setclientid(id=id, verifier='')])
>      check(res)
>      
> +def testCallbackInfoUpdate(t, env):
> +    """A probable callback information update and records
> +       an unconfirmed { v, x, c, k, t } and leaves the
> +       confirmed { v, x, c, l, s } in place, such that t != s.
> +
> +    FLAGS: setclientid all
> +    DEPEND: INIT
> +    CODE: CID4a
> +    """
> +    c1 = env.c1
> +    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
> +
> +    # confirmed { v, x, c, l, s }
> +    (cclientid, cconfirm) = c1.init_connection(clid, verifier=c1.verifier)
> +
> +    # request { v, x, c, k, s } --> unconfirmed { v, x, c, k, t }
> +    ops = [c1.setclientid(clid, verifier=c1.verifier)]
> +    res = c1.compound(ops)
> +    check(res)
> +
> +    tclientid = res.resarray[0].switch.switch.clientid
> +    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
> +
> +    # (t != s)
> +    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
> +        t.fail("Got clientid confirm verifier with all zero!")
> +
> +    if cclientid != tclientid:
> +        t.fail("Return a different clientID for callback information updating!")
> +
> +    if tconfirm == cconfirm:
> +        t.fail("Return a same confirm for callback information updating!")
> +
> +def testConfirmedDiffVerifier(t, env):
> +    """The server has previously recorded a confirmed { u, x, c, l, s }
> +       record such that v != u, l may or may not equal k, and has not
> +       recorded any unconfirmed { *, x, *, *, * } record for x.  The
> +       server records an unconfirmed { v, x, d, k, t } (d != c, t != s).
> +
> +    FLAGS: setclientid all
> +    DEPEND: INIT
> +    CODE: CID4b
> +    """
> +    c1 = env.c1
> +    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
> +
> +    # confirmed { u, x, c, l, s }
> +    (cclientid, cconfirm) = c1.init_connection(clid, verifier=c1.verifier)
> +
> +    # request { v, x, c, k, s } --> unconfirmed { v, x, d, k, t }
> +    ops = [c1.setclientid(clid, verifier="diff")]
> +    res = c1.compound(ops)
> +    check(res)
> +
> +    tclientid = res.resarray[0].switch.switch.clientid
> +    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
> +
> +    # (d != c, t != s)
> +    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
> +        t.fail("Got clientid confirm verifier with all zero!")
> +
> +    if cclientid == tclientid:
> +        t.fail("Return a same clientID for different verifier!")
> +
> +    if tconfirm == cconfirm:
> +        t.fail("Return a same confirm for different verifier!")
> +
> +def testConfUnConfDiffVerifier1(t, env):
> +    """The server has previously recorded a confirmed { u, x, c, l, s }
> +       record such that v != u, l may or may not equal k, and recorded an
> +       unconfirmed { w, x, d, m, t } record such that c != d, t != s, m
> +       may or may not equal k, m may or may not equal l, and k may or may
> +       not equal l.  Whether w == v or w != v makes no difference.  The
> +       server simply removes the unconfirmed { w, x, d, m, t } record and
> +       replaces it with an unconfirmed { v, x, e, k, r } record, such
> +       that e != d, e != c, r != t, r != s.
> +
> +    FLAGS: setclientid all
> +    DEPEND: INIT
> +    CODE: CID4c
> +    """
> +    c1 = env.c1
> +    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
> +
> +    # confirmed { u, x, c, l, s }
> +    (cclientid, cconfirm) = c1.init_connection(clid, verifier=c1.verifier)
> +
> +    # unconfirmed { w, x, d, m, t }
> +    ops = [c1.setclientid(clid, verifier="unconf")]
> +    res = c1.compound(ops)
> +    check(res)
> +
> +    uclientid = res.resarray[0].switch.switch.clientid
> +    uconfirm = res.resarray[0].switch.switch.setclientid_confirm
> +
> +    # request { v, x, c, k, s } --> unconfirmed { v, x, e, k, r }
> +    # (v == w)
> +    ops = [c1.setclientid(clid, verifier="unconf")]
> +    res = c1.compound(ops)
> +    check(res)
> +
> +    tclientid = res.resarray[0].switch.switch.clientid
> +    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
> +
> +    # removes the unconfirmed { w, x, d, m, t }
> +    ops = [c1.setclientid_confirm_op(uclientid, uconfirm)]
> +    res = c1.compound(ops)
> +    check(res, NFS4ERR_STALE_CLIENTID)
> +
> +    # (e != d, e != c, r != t, r != s)
> +    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
> +        t.fail("Got clientid confirm verifier with all zero!")
> +
> +    if cclientid == tclientid or uclientid == tclientid:
> +        t.fail("Return a same clientID for different verifier!")
> +
> +    if tconfirm == cconfirm or tconfirm == uconfirm:
> +        t.fail("Return a same confirm for different verifier!")
> +
> +def testConfUnConfDiffVerifier2(t, env):
> +    """Whether w == v or w != v makes no difference.
> +
> +    FLAGS: setclientid all
> +    DEPEND: INIT
> +    CODE: CID4d
> +    """
> +    c1 = env.c1
> +    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
> +
> +    # confirmed { u, x, c, l, s }
> +    (cclientid, cconfirm) = c1.init_connection(clid, verifier=c1.verifier)
> +
> +    # unconfirmed { w, x, d, m, t }
> +    ops = [c1.setclientid(clid, verifier="unconf")]
> +    res = c1.compound(ops)
> +    check(res)
> +
> +    uclientid = res.resarray[0].switch.switch.clientid
> +    uconfirm = res.resarray[0].switch.switch.setclientid_confirm
> +
> +    # request { v, x, c, k, s } --> unconfirmed { v, x, e, k, r }
> +    # (v != w)
> +    ops = [c1.setclientid(clid, verifier="testconf")]
> +    res = c1.compound(ops)
> +    check(res)
> +
> +    tclientid = res.resarray[0].switch.switch.clientid
> +    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
> +
> +    # removes the unconfirmed { w, x, d, m, t }
> +    ops = [c1.setclientid_confirm_op(uclientid, uconfirm)]
> +    res = c1.compound(ops)
> +    check(res, NFS4ERR_STALE_CLIENTID)
> +
> +    # (e != d, e != c, r != t, r != s)
> +    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
> +        t.fail("Got clientid confirm verifier with all zero!")
> +
> +    if cclientid == tclientid or uclientid == tclientid:
> +        t.fail("Return a same clientID for different verifier!")
> +
> +    if tconfirm == cconfirm or tconfirm == uconfirm:
> +        t.fail("Return a same confirm for different verifier!")
> +
> +def testUnConfReplaced(t, env):
> +    """The server has no confirmed { *, x, *, *, * } for x.  It may or
> +       may not have recorded an unconfirmed { u, x, c, l, s }, where l
> +       may or may not equal k, and u may or may not equal v.  Any
> +       unconfirmed record { u, x, c, l, * }, regardless of whether u == v
> +       or l == k, is replaced with an unconfirmed record { v, x, d, k, t}
> +       where d != c, t != s.
> +
> +    FLAGS: setclientid all
> +    DEPEND: INIT
> +    CODE: CID4e
> +    """
> +    c1 = env.c1
> +    clid = "Clid_for_%s_pid=%i" % (t.code, os.getpid())
> +
> +    # unconfirmed { w, x, d, m, t }
> +    ops = [c1.setclientid(clid, verifier="unconf")]
> +    res = c1.compound(ops)
> +    check(res)
> +
> +    uclientid = res.resarray[0].switch.switch.clientid
> +    uconfirm = res.resarray[0].switch.switch.setclientid_confirm
> +
> +    # request { v, x, c, k, s } --> unconfirmed { v, x, d, k, t }
> +    ops = [c1.setclientid(clid, verifier="diff")]
> +    res = c1.compound(ops)
> +    check(res)
> +
> +    tclientid = res.resarray[0].switch.switch.clientid
> +    tconfirm = res.resarray[0].switch.switch.setclientid_confirm
> +
> +    # removes the unconfirmed { w, x, d, m, t }
> +    ops = [c1.setclientid_confirm_op(uclientid, uconfirm)]
> +    res = c1.compound(ops)
> +    check(res, NFS4ERR_STALE_CLIENTID)
> +
> +    # (d != c, t != s)
> +    if tconfirm == '\x00\x00\x00\x00\x00\x00\x00\x00':
> +        t.fail("Got clientid confirm verifier with all zero!")
> +
> +    if uclientid == tclientid:
> +        t.fail("Return a same clientID for different verifier!")
> +
> +    if tconfirm == uconfirm:
> +        t.fail("Return a same confirm for different verifier!")
> +
>  def testLotsOfClients(t, env):
>      """SETCLIENTID called multiple times
>  
> -- 
> 2.4.3
