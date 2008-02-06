From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: NFS+krb5: Failed to create krb5 context for user with uid 0
Date: Wed, 6 Feb 2008 00:12:01 -0500
Message-ID: <4d569c330802052112q418ffc45u7e20dee3d2a393d7@mail.gmail.com>
References: <1459814D-D960-44A2-947E-F6D0BD46DAC6@zymeworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Luke Cyca" <luke-rgTVnuQaENGakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:32178 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbYBFFMC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2008 00:12:02 -0500
Received: by wr-out-0506.google.com with SMTP id c48so2477218wra.23
        for <linux-nfs@vger.kernel.org>; Tue, 05 Feb 2008 21:12:01 -0800 (PST)
In-Reply-To: <1459814D-D960-44A2-947E-F6D0BD46DAC6-rgTVnuQaENGakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 5, 2008 8:51 PM, Luke Cyca <luke-rgTVnuQaENGakBO8gow8eQ@public.gmane.org> wrote:
> Hello NFS List,
>
> I've been trying to set up some linux clients to work with a Mac OS X
> 10.5 (Leopard) server.  So far I've made some good progress, but run
> into a few problems with Kerberized NFS.  I have the ssh server on
> the linux client fully kerberized with ticket forwarding.  I also
> have the users' home directories mounting from the mac server with
> autofs with sec=krb5.  Users can log in, see their files, and
> everything seems to work great.
>
> The problem is that in syslog I get these errors repeatedly...
> > Feb  5 17:31:39 myclient.domain.com rpc.gssd[8137]: WARNING: Failed
> > to create krb5 context for user with uid 0 with any credentials
> > cache for server myserver.domain.com
> > Feb  5 17:31:39 myclient.domain.com rpc.gssd[8137]: Failed to write
> > error downcall!
>
>
> It seems that whenever root wants to look at the mounted filesystem
> (when running df, for example), it doesn't have permission.  Now I
> know that it's supposed to use machine credentials, and that it
> currently only works with "des-cbc-crc:normal".  I wasn't sure if
> that applied to the server's nfs principal as well, but I did it just
> to be safe.  Here's what I've got in the keytabs...
>
> Client keytab:
> >    3 nfs/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (DES cbc mode with CRC-32)
> >    8 host/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (Triple DES cbc mode with
> > HMAC/sha1)
> >    8 host/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (ArcFour with HMAC/md5)
> >    8 host/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (DES cbc mode with CRC-32)
>
>
> Server keytab:
> > ....
> >    3 host/myserver.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (Triple DES cbc mode with
> > HMAC/sha1)
> >    3 host/myserver.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (ArcFour with HMAC/md5)
> >    3 host/myserver.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (DES cbc mode with CRC-32)
> >    4 nfs/myserver.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org (DES cbc mode with CRC-32)
> > ....
>
> I also recreated the principals on the KDC, and specified only the
> one key type (des-cbc-crc:normal).  Again, not sure if that was
> necessary or not.

If the Mac server code can support other encryption types like Triple
DES and ArcFour, you shouldn't need to limit it to only the
des-cbc-crc key.  The Linux nfs-utils code on the client should be
limiting the negotiated encryption type to des.

I would assume if normal users are able to get a context and talk to
the server, that root using the keytab should be able to do so as
well.


> I can run rpc.gssd with the -n flag, and the error output changes to
> this...
>
> # rpc.gssd -f -n
> > ERROR: GSS-API: error in gss_acquire_cred(): Unspecified GSS
> > failure.  Minor code may provide more information - Unknown code
> > krb5 195
> > WARNING: Failed to create krb5 context for user with uid 0 for
> > server myserver.domain.com
> > Failed to write error downcall!

This looks like a Redhat distro?  "krb5 195" is KRB5_FCC_NOFILE   With
the "-n" flag, you have to manually get credentials for root and put
them in /tmp/krb5cc_0 (or similar).


> If I crank up the verbosity of the output, I get this:
>
> # rpc.gssd -f -vvv
> > handling krb5 upcall
> > Full hostname for 'myserver.domain.com' is 'myserver.domain.com'
> > Full hostname for 'myclient.domain.com' is 'myclient.domain.com'
> > Key table entry not found while getting keytab entry for 'root/
> > myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org'
> > Success getting keytab entry for 'nfs/myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org'
> > Successfully obtained machine credentials for principal 'nfs/
> > myclient.domain.com-Cx6ELD3zwl1XrIkS9f7CXA@public.gmane.org' stored in ccache 'FILE:/tmp/
> > krb5cc_machine_DOMAIN.COM'
> > INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_DOMAIN.COM' are
> > good until 1202297948
> > using FILE:/tmp/krb5cc_machine_DOMAIN.COM as credentials cache for
> > machine creds
> > using environment variable to select krb5 ccache FILE:/tmp/
> > krb5cc_machine_DOMAIN.COM
> > creating context using fsuid 0 (save_uid 0)
> > creating tcp client for server myserver.domain.com
> > creating context with server nfs-mXuENlnwU4l31WWMw7KoMkEOCMrvLtNR@public.gmane.org
> > WARNING: Failed to create krb5 context for user with uid 0 for
> > server myserver.domain.com
> > WARNING: Failed to create krb5 context for user with uid 0 with
> > credentials cache FILE:/tmp/krb5cc_machine_DOMAIN.COM for server
> > myserver.domain.com
> > WARNING: Failed to create krb5 context for user with uid 0 with any
> > credentials cache for server myserver.domain.com
> > doing error downcall
> > Failed to write error downcall!
>
>
>
> Can anybody give me any hints or suggestions?

Why this is failing, I do not know.  What version of Kerberos do you
have?  A packet trace would be helpful.

K.C.
