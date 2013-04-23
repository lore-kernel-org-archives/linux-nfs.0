Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757004Ab3DWShr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 14:37:47 -0400
Subject: Re: Interoperable junctions on Linux
From: Simo Sorce <simo@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: samba-technical@lists.samba.org,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <D7E48414-53C9-45AA-B742-A579ABFC953A@oracle.com>
References: <71999CA2-F6E7-4DE1-9DC3-AED77626DE7F@oracle.com>
	 <1366728674.7239.63.camel@willson.li.ssimo.org>
	 <BDD9FCE5-E573-4E01-A5D9-A8A3811895DD@oracle.com>
	 <1366736069.7239.93.camel@willson.li.ssimo.org>
	 <D7E48414-53C9-45AA-B742-A579ABFC953A@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Apr 2013 14:37:42 -0400
Message-ID: <1366742262.7239.131.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-23 at 14:11 -0400, Chuck Lever wrote:
> On Apr 23, 2013, at 12:54 PM, Simo Sorce <simo@redhat.com> wrote:

> > I do not see mention of LDAP URIs, andyou seem to speak in the singular
> > when mention 'the LDAP server' does it mean you hve no way to specify a
> > pool of LDAP servers for HA ?
> 
> An "NSDB name" (used in a junction) is meant to represent a pool of
> replicated LDAP server resources, or just one LDAP server.  Note that
> specifying IP addresses in FedFS Fileset Names is specifically
> disallowed for this reason.
> 
> A FedFS Fileset Name can indeed be represented by an LDAP URI.  See
> the operational examples in the FedFS NSDB draft.

Sorry I found that after some more searching, the document is vast and I
missed it at first glance.

> > 
> >> An explanation of this data is in an IETF draft:
> >> 
> >> 
> >> http://datatracker.ietf.org/doc/draft-ietf-nfsv4-federated-fs-protocol/
> > 
> >> See chapter 4 for an overview of the schema used for these lists.  An
> >> NFS fileserver converts the LDAP records into an fs_locations4 or
> >> fs_locations_info4 attribute for NFS clients.  Other protocols use a
> >> different representation for communicating this list to clients.
> >> 
> > To be honest the constrains in this document on the LDAP DIT, seem to
> > indicate it will be possible to use this stuff primarily only with a
> > dedicated LDAP server, Dictating how the rootDSE/namingContext should
> > look like is a quite strong demand.
> > 
> > Why do you need a full namingContext for FedFS ?
> > Why a subtree is not sufficient ?
> 
> The document does recommend using a dedicated LDAP service for an
> NSDB, but does not require it.

Ah I didn't realize you recommend a dedicated LDAP server.

> One or more of the namingContext records on an NSDB has a new
> attribute (fedfsNceDN) that points to the FedFS DIT.  So it is
> entirely possible to use an existing LDAP server for storing FedFS
> records, simply by adding that attribute to the namingContext under
> which the FedFS subtree resides.

That 'simply' is not so simple, you may not be allowed to do that.

> The goal is to allow automated discovery of the location of the FedFS
> DIT using a DN advertised in the LDAP server's rootDSE.  NSDB clients
> thus need know only the name of the NSDB service.

You can do the same w/o forcing the attribute to be on the base suffix,
all you need to do is a subtree search with
'&(objctclass=fedfsNsdbContainerInfo)' as part of the filter.
Given this objectclass is used as the container entry main objectclass
it also means the fedfsNceDN would be redundant and could be removed
entirely.

> By default, NSDBs that my tools set up store the FedFS DIT under the
> LDAP server's domain controller suffix, rather than using the special
> "o=fedfs" DN.  By convention the FedFS domain name matches the domain
> controller suffix, but operation doesn't depend on this.
> 
> It is not quite as restrictive as you think, but it is very fiddly to
> set up on industrial strength LDAP servers like OpenLDAP or 389-ds.

Well I have some knowledge in this field, and I do not find it very
fiddly, but I may be biased as I have been working for the past 7 years
to make LDAP+Kerberos simple to manage within the FreeIPA project.
Your requirement to set an objectclass on the base suffix is something I
find particularly unappealing, and no other tool that I know of requires
this (because it is unnecessary).
> 
> > On the security side, you recommend RPCSEC_GSS for NFS, but then TLS
> for
> > LDAP, why not use SASL/GSSAPI for LDAP as well so you need a single
> set
> > of credentials ?
> 
> There are two classes of tasks involving NSDBs: administrative, where
> an administrator is available to provide credential material; and
> fileserver, which is an unattended access performed simply to retrieve
> location lists.
> 
> The purpose of TLS is to allow fileservers to authenticate NSDBs
> without requiring user intervention.  A certificate chain for each
> NSDB is provisioned on fileservers (using the FedFS ADMIN RPC
> protocol).  The fileservers use them with START_TLS each time a
> connection is established to that NSDB.
> 
> SASL/GSSAPI can of course be used when performing administrative
> operations on an NSDB, and that is the plan for the Linux FedFS
> implementation.  As you observed, an administrator can then use the
> same credentials for an RPCGSS-protected FedFS ADMIN service and her
> NSDB.

SASL/GSSAPI can also be used by the file server given the use of
RPCSEC_GSS requires you to have a keytab there. This means I have to
care only to drop a keytab and I get mutual authentication and
encryption of the channel to LDAP w/o having to care to get a x509
certificate and configure the server to trust it directly or drop a
suitable CA Certificate.

I find that properly configuring SSL is a lot more difficult than simply
dropping a keytab in place (especially given you alredy need to do it).

Basically in most setups I encounter for real SSL is effectively
"disabled" and by that I mean that peers are configured to ignore
untrusted certificates, also certificates expire and the whole lifecycle
of using SSL certificates *properly* is a lot more complex than using
GSSAPI with a simple keytab file.

So I strongly recommend you put language in your RFC allowing
SASL/GSSAPI as a mechanism for securing communication to the LDAP server
for both administrative and simple retrieval, you will do a favor to the
implementer allowing conformance w/o having to jump though hoops.


[Sorry for the OT, but this really is something you should get right]


> >> If we are really wily, maybe a small single-purpose daemon can be
> >> constructed from a minimal LDAP server implementation (or from
> >> scratch), and it can listen on its own port or only for loopback
> >> requests.
> > 
> > I think in most cases this is what will actually happen, but you do not
> > need to use a special purpose built server, you can use an existing LDAP
> > server simply specially configured for your needs. It will cause
> > administrative overhead to handle this infrastructure though.
> 
> Don't I know it.
> 
> To simplify initial configuration, I've implemented a script that
> installs OpenLDAP and performs enough configuration to provide a
> stand-alone NSDB, with or without TLS.  I already have a number of C
> tools that can set up the rootDSE and add Fileset Name records on
> either 389-ds or OpenLDAP servers.
> 
> The idea is to allow both types of NSDB (stand-alone, and as part of
> an existing LDAP service), but that kind of generality adds a lot of
> complexity to the set up process and documentation.  Going with just
> one or the other makes life much easier.

I think you should allow the broadest possibilities of course, which is
why I am picking on things like allowing SSAL/GSSAPI explicitly in the
RFC language. Whether people will integrate into existing LDAP server or
not remains to be seen, if we can avoid the need to add an objectlass on
the root suffix I see that we can easily add this a standard feature for
FreeIPA as well (we already provide automount data for example) and
provide management tools in our framework around it.

> >> I think you are suggesting we ignore this problem for now, and just
> >> have the tools pretend the other protocol does not exist, while still
> >> allowing the possibility of storing both types of metadata in the same
> >> filesystem object.  That may be an easy way to get started.
> > 
> > I thought this was what you were proposing actually. With my
> > 'integrator' hat on I would rather quickly define common tools that can
> > handle both, and have the old tools return loud warnings (were possible)
> > if you try to use them.
> 
> The "old" FedFS tools in this case are available because they are one
> of two independent reference implementations required for the IETF
> standardization process.  However, I think solving the problem of
> integrating FedFS ADMIN with an existing DFS implementation on a
> multi-protocol fileserver is going to be very valuable implementation
> experience that can be fed back into the IETF standards process.
> 
> I'm not confident we can fit rpc.fedfsd (Linux's implementation of the
> FedFS RPC ADMIN service) into this model, so we may end up abandoning
> its use for managing FedFS junctions, leaving it only to provisioning
> NSDB certificates.
> 
> > In the Samba case the basic tool is 'ln', not sure we can do much about
> > it :-) But we can certainly patch the RPC code that allows handling via
> > SMB/RPC although I am not quite sure how to populate all the data the
> > SMB world has no concept of, perhaps using 'good defaults' ...
> 
> Exactly the problem.
> 
> My thought was to define a place-holder value for both protocols that
> can be used by our existing tools, for now.  No xattr for symlinks
> created on behalf of DFS, and maybe an empty symlink for junctions
> created by rpc.fedfsd or the nfsref command.
> 
Sound like a good first start to me.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

