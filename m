Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49832 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756358Ab3DWQyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 12:54:33 -0400
Subject: Re: Interoperable junctions on Linux
From: Simo Sorce <simo@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: samba-technical@lists.samba.org,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <BDD9FCE5-E573-4E01-A5D9-A8A3811895DD@oracle.com>
References: <71999CA2-F6E7-4DE1-9DC3-AED77626DE7F@oracle.com>
	 <1366728674.7239.63.camel@willson.li.ssimo.org>
	 <BDD9FCE5-E573-4E01-A5D9-A8A3811895DD@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Apr 2013 12:54:29 -0400
Message-ID: <1366736069.7239.93.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-23 at 11:42 -0400, Chuck Lever wrote:
> > Can you give an example or refernce of what is stored in this XML/JSON
> > blob ? Why do you need structured data there ?
> 
> An "NFS basic junction" stores the location list in place.  Each item
> in a location list contains a number of pieces of data, including: a
> server hostname, an export pathname (which is a list of path
> components), and a number of integer and boolean settings that help
> clients sort which replica of this data they should mount.
> 
> A full explanation of this data is in RFC 5661, section 11.10.  This
> data is returned to an NFS client when it encounters one of these
> objects.  The client can redirect its requests to one of the servers
> and exports listed in the returned data.
> 
> A "FedFS junction" stores a reference to a location list stored in
> LDAP.  The LDAP server's hostname and port number and the UUID of a
> FedFS Fileset Name record are stored in the junction.  The Fileset
> Name record has children, each of which constitute a location (see
> above).

I do not see mention of LDAP URIs, andyou seem to speak in the singular
when mention 'the LDAP server' does it mean you hve no way to specify a
pool of LDAP servers for HA ?

> An explanation of this data is in an IETF draft:
> 
> 
> http://datatracker.ietf.org/doc/draft-ietf-nfsv4-federated-fs-protocol/

> See chapter 4 for an overview of the schema used for these lists.  An
> NFS fileserver converts the LDAP records into an fs_locations4 or
> fs_locations_info4 attribute for NFS clients.  Other protocols use a
> different representation for communicating this list to clients.
> 
To be honest the constrains in this document on the LDAP DIT, seem to
indicate it will be possible to use this stuff primarily only with a
dedicated LDAP server, Dictating how the rootDSE/namingContext should
look like is a quite strong demand.

Why do you need a full namingContext for FedFS ?
Why a subtree is not sufficient ?


On the security side, you recommend RPCSEC_GSS for NFS, but then TLS for
LDAP, why not use SASL/GSSAPI for LDAP as well so you need a single set
of credentials ?

> 
> > 
> >> Today FedFS junctions can contain either a location list or an LDAP
> >> DN.  One option for FedFS is to support only the LDAP DN junction
> >> type, and have a (possibly local) LDAP service available to store the
> >> location information.  The FedFS junction xattr would then always
> >> contain an LDAP URL.  Storing complex data types (a list containing
> >> pathnames, hostnames, integers, and other values) would then be up to
> >> LDAP.
> > 
> > Having to install a whole LDAP server as a pre-requisite seem very heavy
> > handed.
> 
> True.  Today, the LDAP/NSDB pieces are optional if an admin wants to
> support only "NFS basic junctions," for just this reason.
> 
> However there are certain benefits to allowing location lists to be
> managed via LDAP, rather than being specified at junction creation.
> Junctions can share the same location list, for example.  A filesystem
> migration can update a central location list once, rather than having
> to find every junction that references the migrated filesystem.

Understood.

> In addition, storing these lists in a publicly available LDAP service
> means that any fileserver, anywhere, can access the lists.
> 
> If we are really wily, maybe a small single-purpose daemon can be
> constructed from a minimal LDAP server implementation (or from
> scratch), and it can listen on its own port or only for loopback
> requests.

I think in most cases this is what will actually happen, but you do not
need to use a special purpose built server, you can use an existing LDAP
server simply specially configured for your needs. It will cause
administrative overhead to handle this infrastructure though.

[..]

> > Why should we leave a symlink ? Don't we expect to remove junctions for
> > all protocols ?
> 
> The difficulty I have is how we are going to conjoin the
> administrative tools that manage junctions.  I imagine that for some
> time, the tool used for managing DFS junctions will be unaware of
> FedFS junction content, and vice versa.

Yes, for some time one may end up wiping out the other.

> > What I do not get is why are you trying to use the same mechanism (a
> > symlink) but then treat them as independent and separate entities ?
> > What is the aim ?
> > From your premise I thought you wanted to allow parallel functionality,
> > ie a DFS created in samba would be seen as a junction for nfs and
> > vice-versa, but the latter points seem to not allow that ?
> 
> FedFS junctions can list both NFS and SMB (and other types).  The SMB
> parts are not defined by the IETF, since SMB is a proprietary protocol
> controlled by Microsoft.
> 
> One way to have DFS and FedFS information in the same filesystem
> object is to have one object that can contain both.  The tools then
> have to be designed not to step on each other.  Eventually we figure
> out how to make this seamless.
> 
> I think you are suggesting we ignore this problem for now, and just
> have the tools pretend the other protocol does not exist, while still
> allowing the possibility of storing both types of metadata in the same
> filesystem object.  That may be an easy way to get started.

I thought this was what you were proposing actually. With my
'integrator' hat on I would rather quickly define common tools that can
handle both, and have the old tools return loud warnings (were possible)
if you try to use them.

In the Samba case the basic tool is 'ln', not sure we can do much about
it :-) But we can certainly patch the RPC code that allows handling via
SMB/RPC although I am not quite sure how to populate all the data the
SMB world has no concept of, perhaps using 'good defaults' ...

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

