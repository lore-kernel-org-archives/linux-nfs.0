Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60424 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753187AbcLOT2A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Dec 2016 14:28:00 -0500
Date: Thu, 15 Dec 2016 14:27:59 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [libnfsidmap RFC PATCH] libnfsidmap: add support for multiple
 domains
Message-ID: <20161215192759.s56kojg5upnddx2f@tonberry.usersys.redhat.com>
References: <1481128586-53009-1-git-send-email-smayhew@redhat.com>
 <20161214142623.GA30113@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161214142623.GA30113@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Dec 2016, J. Bruce Fields wrote:

> On Wed, Dec 07, 2016 at 11:36:25AM -0500, Scott Mayhew wrote:
> > Quick disclaimer -- this is different than the multi-domain support
> > described in RFC 8000.  In the description below I'm really using
> > 'multi-domain' to mean 'multiple AD/IdM domains', rather than multiple
> > NFSv4 domains.  
> > 
> > NFSv4 id mapping on Linux does not work well in multi-domain
> > environments.  RFCs 3530, 5661, and 7530 all describe the fattr4_owner
> > and fattr4_owner_group strings in the form "user@dns_domain".
> > 
> > The Linux libnfsidmap nssswitch plugin currently treats that domain as
> > an arbitrary string.  As long as the domain part of the incoming string
> > matches the Domain parameter of the idmapd.conf, the plugin strips off
> > the domain and does a getpwnam() with what's left over.
> > 
> > When a Linux machine is joined to an environment involving multiple AD
> > or IdM domains, it is usually necessary for usernames to be qualified
> > with the domain, either in a user principal format (e.g.
> > "smayhew@ad.example.com") or a down-level logon name format (e.g.
> > "AD\smayhew").  
> > 
> > When an environment with just Linux NFS clients and servers, the
> > machines will all use this format the libnfsimap plugin will
> > automatically format the username in one of these two forms, because
> > libnfsidmap is just using the name that is returned from getpwuid()...
> > so in the above example, if the NFSv4 domain in idmapd.conf is
> > configured as "example.com", the full fattr4_owner might appear as
> > "smayhew@ad.example.com@example.com" if the machines are using SSSD, and
> > "AD\smayhew@example.com" if they're using Winbind.
> > 
> > Non-Linux NFS servers do not do that.
> > 
> > DATA ONTAP maps a uid to a short username and then appends the NFSv4 id
> > mapping domain to that.  The nsswitch plugin is unable to map those,
> > because once it strips off the domain it will be unable to resolve the
> > short username.  It's possible to configure the Linux clients that are
> > using SSSD to be able to use the short usernames by turning off the
> > subdomains_provider and explicitly adding stanzas for each trusted
> > domain in the sssd.conf.  This works as long as each username & uid is
> > unique across all the trusted domains.  For example if you have
> > subdomains "na", "emea", and "apac", then it will not work (or rather it
> > will be unpredictable) if each of those domains has an "smayhew" user...
> > but otherwise it will work.  But there's no corresponding solution for
> > Linux clients that are using Winbind... and and solution does not work
> > for other NFS servers.
> > 
> > The NFS v4.1 server in Microsoft Windows does not appear to allow the
> > NFSv4 domain to be configured at all.  It just sends the names in UPN
> > format, so it's essentially treating the AD domain as the NFSv4 domain.
> > The Windows NFS v4.1 server is therefore capable of working with
> > multiple domains.  Since the current libnfsidmap nsswitch plugin only
> > allows a single domain to be configured, it's only able to map users
> > from that single domain.
> > 
> > EMC Isilon servers are also capable of using multiple domains by
> > unchecking the "Enable NFSv4 Replace Domain" box on the NFS Zone
> > Settings in the web UI or via 'isi nfs settings zone modify
> > --nfsv4-replace-domain no' on the command line.  This causes the Isilon
> > to send AD/IdM domain instead of the NFSv4 domain value in the
> > fattr4_owner and fattr4_owner_group strings.  Again, since the current
> > libnfsidmap plugin only allows a single domain to be configured, it's
> > only able to users from a single domain.
> > 
> > This patch adds a new plugin called 'multidom' (I'm not attached to the
> > name and open to suggestions.  Maybe something like 'nostripdomain'
> > would be better).
> > 
> > What it does is adds another parameter 'Domain-List' to the idmap.conf.
> > That parameter takes (unsurprisingly) a list of domains, in much the
> > same way the Local-Realms parameter works.  The value specified in the
> > Domain parameter does not have to be in the Domain-List.  When the
> > Domains list is populated, the plugin does a few things:
> > 1. For name-to-id mapping, it compares the domain in the attribute to
> > the list of domains.  If it's not in the list, it gets mapped to the uid
> > for nobody.
> > 2. If the domain in the attribute is in the list of domains, then that
> > attibute is passed as-is to getpwnam() (or getgrnam() if its a group).
> > IOW the domain is NOT stripped off.
> > 3. For id-to-name mapping, after the getpwuid() (or getgrgid()) call,
> > the domain in the result is compared to the Domains list... if it's not
> > in the list, the the id is mapped to the nobody string... even if the
> > name was otherwise resolved successfully.
> 
> Dumb questions:
> 
> 	- Do we even need the list, or can we leave that decision to
> 	  whatever's really mapping the names?  If the admin already set
> 	  up things to map @some-weird-domain then why do we need them
> 	  to whitelist that domain again here?

We definitely don't need the domain list.  The reason I added the
whitelist was because without it, it pretty much felt like it was
completely tossing the NFSv4 domain aside.  With the whitelist, it at
least feels like the admin has the ability to say 'we want to map
domains W, X, and Y, but not Z'.  I'd be perfectly happy to toss that
out.  Then it would behave pretty much like the plugin shipped with SSSD
(but without having to talk to SSSD).

> 	- should something like this method be the default?  Or is there
> 	  a way we can auto-detect this kind of setup?

I'd rather leave it as a separate plugin that can be inserted ahead of
the nsswitch plugin, that way the whole thing can be yanked out in the
future if desired.  Also I can't really think of a way to auto-detect
whether it should be used or not.

-Scott

> 
> In general idmapper configuration has been a bit of an annoyance and
> anything we can do to help more admins ignore it is good.
> 
> Anyway, seems like a major improvement, thanks for doing this.
> 
> --b.
> 
> > 
> > With the plugin enabled I'm able to map users from multiple AD/IdM
> > domains.
> > 
> > 
> > ot@rhel6client ~]# cat /etc/idmapd.conf
> > [General]
> > Domain = smayhew.local
> > 
> > [Multi-Domain] 
> > Domain-List = smayhew.local,ad.smayhew.local,lab.smayhew.local
> > 
> > [Mapping]
> > Nobody-User = nobody
> > Nobody-Group = nobody
> > 
> > [Translation]
> > Method = multidom,nsswitch
> > 
> > [root@rhel6client ~]# ls -l /mnt/t
> > total 10
> > -rw-rw-r--. 1 amy@lab.smayhew.local       domain users@lab.smayhew.local 29 Sep 26 15:22 written-by-amy
> > -rw-r--r--. 1 barney@smayhew.local        domain users@smayhew.local     29 Sep 26 15:22 written-by-barney
> > -rw-rw-r--. 1 bart@ad.smayhew.local       domain users@ad.smayhew.local  29 Sep 26 15:22 written-by-bart
> > -rw-rw-r--. 1 bender@lab.smayhew.local    domain users@lab.smayhew.local 29 Sep 26 15:22 written-by-bender
> > -rw-r--r--. 1 betty@smayhew.local         domain users@smayhew.local     29 Sep 26 15:22 written-by-betty
> > -rw-r--r--. 1 fred@smayhew.local          domain users@smayhew.local     29 Sep 26 15:22 written-by-fred
> > -rw-rw-r--. 1 fry@lab.smayhew.local       domain users@lab.smayhew.local 29 Sep 26 15:23 written-by-fry
> > -rw-rw-r--. 1 hermes@lab.smayhew.local    domain users@lab.smayhew.local 29 Sep 26 15:22 written-by-hermes
> > -rw-rw-r--. 1 homer@ad.smayhew.local      domain users@ad.smayhew.local  29 Sep 26 15:22 written-by-homer
> > -rw-rw-r--. 1 kif@lab.smayhew.local       domain users@lab.smayhew.local 29 Sep 26 15:23 written-by-kif
> > -rw-rw-r--. 1 leela@lab.smayhew.local     domain users@lab.smayhew.local 29 Sep 26 15:23 written-by-leela
> > -rw-rw-r--. 1 lisa@ad.smayhew.local       domain users@ad.smayhew.local  29 Sep 26 15:22 written-by-lisa
> > -rw-rw-r--. 1 maggie@ad.smayhew.local     domain users@ad.smayhew.local  29 Sep 26 15:22 written-by-maggie
> > -rw-rw-r--. 1 marge@ad.smayhew.local      domain users@ad.smayhew.local  29 Sep 26 15:22 written-by-marge
> > -rw-rw-r--. 1 professor@lab.smayhew.local domain users@lab.smayhew.local 29 Sep 26 15:23 written-by-professor
> > -rw-rw-r--. 1 smayhew@ad.smayhew.local    domain users@ad.smayhew.local  29 Sep 26 15:22 written-by-smayhew
> > -rw-r--r--. 1 wilma@smayhew.local         domain users@smayhew.local     29 Sep 26 15:22 written-by-wilma
> > -rw-rw-r--. 1 zapp@lab.smayhew.local      domain users@lab.smayhew.local 29 Sep 26 15:23 written-by-zapp
> > -rw-rw-r--. 1 zoidberg@lab.smayhew.local  domain users@lab.smayhew.local 29 Sep 26 15:23 written-by-zoidberg
> > 
> > This also works on systems using Winbind instead of SSSD.  The
> > idmap.conf is the same, with the exception of an additional parameter
> > 'Reformat-Group-For-Winbind-Query = true' in the '[Multi-Domain]'
> > stanza.
> > 
> > [root@rhel6wbnfs ~]# ls -l /mnt/t
> > total 10
> > -rw-rw-r--. 1 LAB\amy        LAB\domain users     29 Sep 26 15:22 written-by-amy
> > -rw-r--r--. 1 SMAYHEW\barney SMAYHEW\domain users 29 Sep 26 15:22 written-by-barney
> > -rw-rw-r--. 1 AD\bart        AD\domain users      29 Sep 26 15:22 written-by-bart
> > -rw-rw-r--. 1 LAB\bender     LAB\domain users     29 Sep 26 15:22 written-by-bender
> > -rw-r--r--. 1 SMAYHEW\betty  SMAYHEW\domain users 29 Sep 26 15:22 written-by-betty
> > -rw-r--r--. 1 SMAYHEW\fred   SMAYHEW\domain users 29 Sep 26 15:22 written-by-fred
> > -rw-rw-r--. 1 LAB\fry        LAB\domain users     29 Sep 26 15:23 written-by-fry
> > -rw-rw-r--. 1 LAB\hermes     LAB\domain users     29 Sep 26 15:22 written-by-hermes
> > -rw-rw-r--. 1 AD\homer       AD\domain users      29 Sep 26 15:22 written-by-homer
> > -rw-rw-r--. 1 LAB\kif        LAB\domain users     29 Sep 26 15:23 written-by-kif
> > -rw-rw-r--. 1 LAB\leela      LAB\domain users     29 Sep 26 15:23 written-by-leela
> > -rw-rw-r--. 1 AD\lisa        AD\domain users      29 Sep 26 15:22 written-by-lisa
> > -rw-rw-r--. 1 AD\maggie      AD\domain users      29 Sep 26 15:22 written-by-maggie
> > -rw-rw-r--. 1 AD\marge       AD\domain users      29 Sep 26 15:22 written-by-marge
> > -rw-rw-r--. 1 LAB\professor  LAB\domain users     29 Sep 26 15:23 written-by-professor
> > -rw-rw-r--. 1 AD\smayhew     AD\domain users      29 Sep 26 15:22 written-by-smayhew
> > -rw-r--r--. 1 SMAYHEW\wilma  SMAYHEW\domain users 29 Sep 26 15:22 written-by-wilma
> > -rw-rw-r--. 1 LAB\zapp       LAB\domain users     29 Sep 26 15:23 written-by-zapp
> > -rw-rw-r--. 1 LAB\zoidberg   LAB\domain users     29 Sep 26 15:23 written-by-zoidberg
> > 
> > -Scott
> > 
> > Scott Mayhew (1):
> >   libnfsidmap: add support for multiple domains
> > 
> >  Makefile.am   |   5 +-
> >  idmapd.conf   |  26 +++-
> >  idmapd.conf.5 |  40 ++++++-
> >  multidom.c    | 379 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  4 files changed, 445 insertions(+), 5 deletions(-)
> >  create mode 100644 multidom.c
> > 
> > -- 
> > 2.7.4
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
