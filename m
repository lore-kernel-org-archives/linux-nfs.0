From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Kerberized NFSv4 with AD - Errors received
Date: Tue, 30 Oct 2007 16:51:46 -0400
Message-ID: <4d569c330710301351i12ad379ft27c6f1b6600502aa@mail.gmail.com>
References: <cf8a6bbc0710300914r6302613emf09dc5d445cbe586@mail.gmail.com>
	<4d569c330710300940q7ee25e95g47ab5395f4917e34@mail.gmail.com>
	<cf8a6bbc0710301302j1f8e014en19d91068fcb03b93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Felderi Santiago" <cibao5@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Imy3q-0001ys-1t
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 13:51:42 -0700
Received: from rv-out-0910.google.com ([209.85.198.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Imy3v-0002Nz-EC
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 13:51:47 -0700
Received: by rv-out-0910.google.com with SMTP id g11so7269208rvb
	for <nfs@lists.sourceforge.net>; Tue, 30 Oct 2007 13:51:47 -0700 (PDT)
In-Reply-To: <cf8a6bbc0710301302j1f8e014en19d91068fcb03b93@mail.gmail.com>
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

AD is trying to include PAC information in the ticket, which makes the
packets too big for UDP.  It should switch to TCP if possible.  There
is an option to tell AD not to include PAC information for a given
service principal.  I don't recall exactly what it is, or how to set
it.

The client thinks that a context was negotiated, so I think you are
getting past that.  Are there error messages on the server?  Can you
send me the packet trace?

K.C.

On 10/30/07, Felderi Santiago <cibao5@gmail.com> wrote:
>
> We're not really seeing an error perse but the Kerberized mount is not
> working.
>
> Sorry for not being clear.  I updated the keytab and included additional
> servicePrincipalNames for nfs, so nfs/hostname.domainname.com.  I also
> changed the UPN of the computer account.
>
> I am testing on:
>
> SUSE SLES 10 SP1 with nfs-utils-1.0.7-36.26
>
> I ran a Network trace and see a Kerberos error which is a step in the right
> direction in terms of figuring out what's going on.  I used Wireshark and
> see the following.  Hmmm...wonder what's going on.
>
> 134 2.775752 172.17.0.159 172.17.0.44 KRB5 KRB Error:
> KRB5KRB_ERR_RESPONSE_TOO_BIG[Packet size limited during
> capture]
>
> Thanks for the help!
>
> Fel.
>
>
>
> On 10/30/07, Kevin Coffman <kwc@citi.umich.edu> wrote:
> > On 10/30/07, Felderi Santiago <cibao5@gmail.com> wrote:
> > > Hello everyone,
> > >
> > > I am working on trying to get Kerberized NFSv4 working with AD.  At this
> > > point everything seems to be setup correctly.  The machine has been
> joined
> > > to AD, the keytab has been updated with the appropriate entries and the
> > > computer account has the appropriate servicePrincipal and userPrincipal
> > > Names.  The Kerberized NFS Share resides on a Filer.
> > >
> > > When trying to mount the share on the client side I get the following
> error
> > > messages.
> > >
> > > Does anyone understand why we're getting this error?  Any help or
> insight
> > > would be very appreciated.
> > >
> > > Thanks!
> > >
> > > Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list
> Oct
> > > 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list Oct
> 29
> > > 20:03:33 dev-unix-shell01 rpc.gssd[3284]: handling krb5 upcall Oct 29
> > > 20:03:33 dev-unix-shell01 rpc.gssd[3284]: Using keytab file
> > > '/etc/krb5.keytab'
> > > Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: INFO: Credentials in CC
> > > 'FILE:/tmp/krb5cc_machine_<DOMAIN>are good until
> 1193722038
> > > Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: using
> > > FILE:/tmp/krb5cc_machine_<DOMAIN> as credentials cache
> for
> > > machine creds Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: using
> > > environment variable to select krb5 ccache
> > > FILE:/tmp/krb5cc_machine_<DOMAIN>
> > > Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating context using
> euid
> > > 0 (save_uid 0) Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating
> tcp
> > > client for server prod-fs-sv1.<domainname>
> > > Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: creating context with
> > > server nfs@prod-fs-sv1.<domain_name>
> > > Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: DEBUG:
> > > serialize_krb5_ctx: lucid version!
> > > Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: doing downcall Oct 29
> > > 20:03:34 dev-unix-shell01 rpc.gssd[3284]: processing client list
> >
> > There is no error message here.  This is all normal, apparently
> > successful, debug output.
> >
> > What error are you seeing?
> >
> > BTW, you said, "the keytab has been updated with the appropriate
> > entries".  I'm not sure what this means, but I hope it does not mean
> > that keys for non-supported enctypes were simply manually removed from
> > the keytab file using ktutil.
> >
> > K.C.
> >
>
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
