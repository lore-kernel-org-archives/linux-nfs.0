From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: NFSv3/4 and Kerberos.
Date: Thu, 13 Apr 2006 16:37:05 -0400
Message-ID: <4d569c330604131337l495b9b4lb39cd7a580ec98ea@mail.gmail.com>
References: <2b585fc90604131147t3ffa7abemc9f50f76a7a0d3a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUABB-0006dT-P7
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 15:20:45 -0700
Received: from nproxy.gmail.com ([64.233.182.189])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FUABA-0006Jx-E6
	for nfs@lists.sourceforge.net; Thu, 13 Apr 2006 15:20:45 -0700
Received: by nproxy.gmail.com with SMTP id l36so1175876nfa
        for <nfs@lists.sourceforge.net>; Thu, 13 Apr 2006 15:20:40 -0700 (PDT)
To: "Christopher Smith" <csmithere@gmail.com>
In-Reply-To: <2b585fc90604131147t3ffa7abemc9f50f76a7a0d3a6@mail.gmail.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This sounds kind of familiar, but it has been quite a while since I've
dealt with this level of code.

Is cmsmith-ntap both nfs client and nfs server?  Any errors from the
server (rpc.svcgssd)?

This *might* be related.  Each machine should only have its own keys
in its keytab.  (If katana is the nfs client, it should not have
cmsmith-ntap's key, which it is using, in its keytab.)

K.C.


On 4/13/06, Christopher Smith <csmithere@gmail.com> wrote:
> Folks--
>
> I'm working on doing some testing of NFSv3 and NFSv4, and I'm running
> into the following error (shown from rpc.gssd -vvv -f):
>
> rpcsec_gss: xdr_rpc_gss_init_args: encode success (token 0x9e7b550:531)
> rpcsec_gss: in authgss_refresh()
> rpcsec_gss: gss_init_sec_context: A token was invalid - No error
> rpcsec_gss: in authgss_destroy()
> rpcsec_gss: in authgss_destroy_context()
> WARNING: Failed to create krb5 context for user with uid 0 for server
> cmsmith-ntap.hq.example.com


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
