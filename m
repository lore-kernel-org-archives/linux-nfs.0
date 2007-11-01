From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Linux NFSv4 Server and Client using Windows 2K3 AD/KDC
Date: Wed, 31 Oct 2007 22:51:39 -0400
Message-ID: <4d569c330710311951m70d57030qd69e0a0e4d02ba54@mail.gmail.com>
References: <47293938.4010407@devrandom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jason D. McCormick" <jason@devrandom.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InQ9h-0006WX-3H
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 19:51:39 -0700
Received: from rv-out-0910.google.com ([209.85.198.186])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1InQ9l-00010T-0E
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 19:51:42 -0700
Received: by rv-out-0910.google.com with SMTP id g11so1141798rvb
	for <nfs@lists.sourceforge.net>; Wed, 31 Oct 2007 19:51:40 -0700 (PDT)
In-Reply-To: <47293938.4010407@devrandom.org>
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

On 10/31/07, Jason D. McCormick <jason@devrandom.org> wrote:
> Hello All,
>
>   I'm trying to setup a Linux NFSv4 server and client using Windows 2K3
> AD as the KDC (Domain/Realm is AD.EXAMPLE.ORG).  I've successfully set
> this up using MIT Kerberos before so the problems appear to be with the
> Windows KDC portion of the setup.  I'm not sure this is supported with
> Linux clients and servers -- most of the reading I see using Windows
> KDCs is using NetApp filers.
>
>   When attempting to mount the NFS export with '-o sec=krb5', I get a
> timeout and an eventual failure to mount.  Running the client's rpc.gssd
> in the foreground with verbose logging yields:
>
> WARNING: Failed to create krb5 context for user with uid 0 for server
> nfs-server.example.com
> WARNING: Failed to create krb5 context for user with uid 0 with
> credentials cache FILE:/tmp/krb5cc_machine_AD.EXAMPLE.COM for server
> nfs-server.example.com
> WARNING: Failed to create krb5 context for user with uid 0 with any
> credentials cache for server nfs-server.example.com
>
> Running the server's rpc.svcgssd in the foreground with verbose logging
> yields:
>
> handling null request
> WARNING: gss_accept_sec_context failed
> ERROR: GSS-API: error in handle_nullreq: gss_accept_sec_context():
> Miscellaneous failure - Key table entry not found
> WARNING: failed to write message
>
> I see it claims there's no key table entry found, but from looking at
> the message output in '-vvvv' it appears to be asking for
> nfs/nfs-server.example.com@AD.EXAMPLE.COM like I would expect.  I have
> the domain_realm mappings configured correctly ({,.}example.com =
> AD.EXAMPLE.COM), the nfs/host principals stashed correctly in
> /etc/krb5.keytab, they are using des-cbc-crc and I can use them
> perfectly with a 'kinit -k nfs/host@REALM' command.  On the server, for
> example:
>
> # klist -k -e
> Keytab name: FILE:/etc/krb5.keytab
> KVNO Principal
> ---- -------------------------------------------------------------
>    3 host/nfs-server.example.com@AD.EXAMPLE.COM (DES cbc mode with
>      CRC-32)
>    3 nfs/nfs-server.example.com@AD.EXAMPLE.COM (DES cbc mode with
>      CRC-32)
>
> I've read a lot of the usual places like Mike Eisler's blog and mailing
> list and I've not found anything like what I'm experiencing (or else I'm
> not searching on the right terms).
>
> Anyone able to help?  I've tried a couple of different versions of
> nfs-utils to see if there's an incompatibility and I've run into the
> same problem with all of them.
>
> Thanks.
>
> -- Jason

Two guesses:

1) Are you sure the server's kernel has the necessary crypto compiled
in, or modules loaded?

2) My other guess is that somehow the service ticket being presented
to the server was encrypted with rc4-hmac or something, and it is
looking for a key with that name and enctype in the keytab and not
finding it.  A look at a packet trace would prove or disprove this
guess.

K.C.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
