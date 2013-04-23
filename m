Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43840 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755914Ab3DWUdL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 16:33:11 -0400
Subject: Re: Interoperable junctions on Linux
From: Simo Sorce <simo@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: samba-technical@lists.samba.org,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <08635513-9147-4AE9-80E5-0122CB9099CB@oracle.com>
References: <71999CA2-F6E7-4DE1-9DC3-AED77626DE7F@oracle.com>
	 <1366728674.7239.63.camel@willson.li.ssimo.org>
	 <BDD9FCE5-E573-4E01-A5D9-A8A3811895DD@oracle.com>
	 <1366736069.7239.93.camel@willson.li.ssimo.org>
	 <D7E48414-53C9-45AA-B742-A579ABFC953A@oracle.com>
	 <1366742262.7239.131.camel@willson.li.ssimo.org>
	 <08635513-9147-4AE9-80E5-0122CB9099CB@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Apr 2013 16:33:06 -0400
Message-ID: <1366749186.7239.149.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-23 at 15:52 -0400, Chuck Lever wrote:
> On Apr 23, 2013, at 2:37 PM, Simo Sorce <simo@redhat.com> wrote:
> 
> > On Tue, 2013-04-23 at 14:11 -0400, Chuck Lever wrote:

> >> One or more of the namingContext records on an NSDB has a new
> >> attribute (fedfsNceDN) that points to the FedFS DIT.  So it is
> >> entirely possible to use an existing LDAP server for storing FedFS
> >> records, simply by adding that attribute to the namingContext under
> >> which the FedFS subtree resides.
> > 
> > That 'simply' is not so simple, you may not be allowed to do that.
> 
> In which case, you set up your own LDAP server, where you _are_ allowed to do it.

Of course, if forced that is an option, but I would rather see to it
that we do not add barriers to adoption that force people to deploy
additional LDAP servers where possible.

> > 
> >> The goal is to allow automated discovery of the location of the FedFS
> >> DIT using a DN advertised in the LDAP server's rootDSE.  NSDB clients
> >> thus need know only the name of the NSDB service.
> > 
> > You can do the same w/o forcing the attribute to be on the base suffix,
> > all you need to do is a subtree search with
> > '&(objctclass=fedfsNsdbContainerInfo)' as part of the filter.
> > Given this objectclass is used as the container entry main objectclass
> > it also means the fedfsNceDN would be redundant and could be removed
> > entirely.
> 
> Would your search filter be able to find a fedfsNsdbContainerInfo
> objectclass in a namingContext _and_ under it?  The search base is
> determined first by this search, then the NSDB client can search for a
> particular Fileset Name under that base DN.

That's what subtree searches are for, if your search has scope subtree
you'll find *any* entry that has that objectclass in the specific
namingContext you are using for the search.

> Although I have been working to simplify this mechanism as specified
> in the NSDB document, I don't remember the specific reason we require
> namingContext changes (I inherited this work from the original
> authors).  I agree that a subtree search would be simpler.

It is, it would be nice if you'd allow that.

> But we may be too far along in the standards process to address this
> concern in this iteration of the protocol. If we can't fix this
> protocol specification, it's certainly possible to construct our own
> implementation without fedfsNceDn that does not interoperate, and then
> document our implementation in a new protocol specification.

Well the change is not huge, you could allow both with minor language
changes. Knowing there is an interoperability issue and not addressing
it when it is simple to do so is not really friendly to implementers.

> > 
> >> By default, NSDBs that my tools set up store the FedFS DIT under the
> >> LDAP server's domain controller suffix, rather than using the special
> >> "o=fedfs" DN.  By convention the FedFS domain name matches the domain
> >> controller suffix, but operation doesn't depend on this.
> >> 
> >> It is not quite as restrictive as you think, but it is very fiddly to
> >> set up on industrial strength LDAP servers like OpenLDAP or 389-ds.
> > 
> > Well I have some knowledge in this field, and I do not find it very
> > fiddly, but I may be biased as I have been working for the past 7 years
> > to make LDAP+Kerberos simple to manage within the FreeIPA project.
> > Your requirement to set an objectclass on the base suffix is something I
> > find particularly unappealing, and no other tool that I know of requires
> > this (because it is unnecessary).
> 
> I presented the NSDB schema to both OpenLDAP and 389-ds developers
> last year.  Neither group suggested that fiddling with an LDAP
> server's rootDSE was onerous (although they didn't like the way we
> were doing it, and that has since been changed).

I have the integrator perspective, which differ from the core developers
perspective at times.

> If you can provide back up documentation for your root suffix issue, I
> can put this in front of the Working Group.  "It's particularly
> unappealing" is not going to fly ;-)  Can you help me formulate a
> proper problem statement (off list, of course)?

I am not sure what documentation you require, what you ask *can* be done
to an LDAP server, it's not like your are doing something forbidden. It
is just not what all other extensions do. In FreeIPA I would be
uncomfortable adding that stuff in the root suffix, doesn't mean I will
Veto it, but I might see if I can get away not following the standard in
that regard if we come to integrate this as a default feature.

For Active Directory admins (should somoene want to use AD for this
information) changing the root suffix may also be very unappealing (if
possible at all), although they will find extending the schema
problematic already.

It is a matter of best practices and 'acceptability' more than anything.
It is more acceptable as a solution if you do not have this particular
constraint, which is technically unnecessary so I am not sure why the
RFC process should be dead set on mandating it. Surely you can relax
some MUST here and there ?

> > SASL/GSSAPI can also be used by the file server given the use of
> > RPCSEC_GSS requires you to have a keytab there. This means I have to
> > care only to drop a keytab and I get mutual authentication and
> > encryption of the channel to LDAP w/o having to care to get a x509
> > certificate and configure the server to trust it directly or drop a
> > suitable CA Certificate.
> > 
> > I find that properly configuring SSL is a lot more difficult than simply
> > dropping a keytab in place (especially given you alredy need to do it).
> > 
> > Basically in most setups I encounter for real SSL is effectively
> > "disabled" and by that I mean that peers are configured to ignore
> > untrusted certificates, also certificates expire and the whole lifecycle
> > of using SSL certificates *properly* is a lot more complex than using
> > GSSAPI with a simple keytab file.
> 
> Having just implemented TLS support in my NSDB client, I can attest to the challenges.
> 
> > So I strongly recommend you put language in your RFC allowing
> > SASL/GSSAPI as a mechanism for securing communication to the LDAP server
> > for both administrative and simple retrieval, you will do a favor to the
> > implementer allowing conformance w/o having to jump though hoops.
> 
> We have discussed SASL/GSSAPI with LDAP server implementors, and it is
> already on the radar.  It should be possible to introduce with another
> FEDFS_SEC connection security type, but the plan was to introduce
> SASL/GSSAPI in the next version of the NSDB protocol.

Ok, if it is on your radar I am fine. Not sure why you say NSDB
'protocol' I am assuming this is the LDAP protocol, or are you planning
on deviating from LDAP ??

> Again, documentation references would help me formulate a problem
> statement to address this at this late date, and we can still take the
> approach of building something that doesn't interoperate for now if we
> think this is a strong requirement.

What sort of documentation ?

SASL/GSSAPI is a standard SASL mechanism and SASL is a
standard ,echanism for LDAP binds, so all the references should be easy.

Using SASL/GSSAPI would make it easier for some directory services that
are tightly integrated with Kerberos.
In my case, the FreeIPA project uses SASl/GSSAPI with LDAP, although we
do configure and support also STRAT_TLS by default.
In the Active Directory case SSL is not enabled by default (and it is
hard and unconvenient to configure), while SASL/GSSAPI is.

So SASL/GSSAPI would be an easier route for adoption in some circles.


> > I think you should allow the broadest possibilities of course, which is
> > why I am picking on things like allowing SSAL/GSSAPI explicitly in the
> > RFC language.
> 
> Because there are so many moving parts to FedFS, I have striven to
> make set up as simple as possible.  Just because the spec says you can
> do something, doesn't mean it is wise to do it, or that you should
> offer it as an option, nor is it appropriate for every implementation.

I think we have al;ready determined SASL/GSSAPI is actually simpler than
TLS, so if you are striving for simplicity... :)

> Practically speaking, implementation resources are limited.  I have to
> pick the features that offer the most bang for the buck.  I can't
> afford to implement everything and see which features are appealing.
> (And besides, I thought the idea of open source was to let people
> scratch their own itches -- if someone wants a feature, they have the
> opportunity to add it themselves).

Not sure what there is to implement, if you are using a LDAP library in
your client, switching on SASL/GSSAPI is a very few lines of code if
any.

> > Whether people will integrate into existing LDAP server or
> > not remains to be seen, if we can avoid the need to add an objectlass on
> > the root suffix I see that we can easily add this a standard feature for
> > FreeIPA as well (we already provide automount data for example) and
> > provide management tools in our framework around it.
> 
> Does FreeIPA manage DFS metadata as well?

No, DFS data requires Active Directory in the CIFS worls, and freeIPA is
not an AD implementation. FreeIPA is focused on Linux clients though so
FedFS junctions may be appealing to support.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

