Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16582 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756816AbcKKQUh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2016 11:20:37 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Question about nfsdcltrack --storagedir
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87oa1nklug.fsf@notabene.neil.brown.name>
Date: Fri, 11 Nov 2016 11:19:24 -0500
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B7F56198-AA01-453B-A6ED-407B8D266724@oracle.com>
References: <87k2cdmi26.fsf@notabene.neil.brown.name> <1478692626.2394.9.camel@redhat.com> <877f8c9pku.fsf@notabene.neil.brown.name> <1478739358.2442.1.camel@redhat.com> <8B417571-FAA9-4793-AE5F-F71BCDF7ADD5@oracle.com> <87oa1nklug.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hiya Neil-

> On Nov 10, 2016, at 5:32 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Fri, Nov 11 2016, Chuck Lever wrote:
> 
>>> 
>>> No objection here, especially if we make it so that we have existing
>>> behavior when there is no config file. nfs-utils even has some config
>>> file parsing routines now in support/nfs that should be sufficient.
>> 
>> Just a general thought:
>> 
>> It's fine to store the configuration data under /etc, but for new
>> administrative interfaces, please create a command line UI which
>> is used to edit said configuration data. This makes it much easier
>> for users to script administrative changes, to build GUIs around,
>> and for our Q/A teams to construct automated tests.
> 
> If that is an important concern (and I don't disagree) then I would
> suggest dropping the idea of a config file with sections and just have a
> file with simple (case sensitive) "name=value" assignments.

I'm not necessarily advocating this, but we already have a single
central key-value file that stores NFS configuration information
(at least on RH-based distros), and that's /etc/sysconfig/nfs.


> Then sed
> can be used to modify the file.
> 
> Or.... just use git to modify the config file.
> 
>  sudo git config --file /etc/idmapd.conf mapping.nobody-user neilb
> 
> did what I expected it to do :-)

Clever! But to be a little more clear, this is not about the
technology used to modify a config file.

After an administrator finds and modifies the correct file, there's
a set of dodgy distribution-dependent instructions to figure out what
daemons need to be poked with a sharp stick to pick up the new config.

For idmapd.conf changes, for example, it's going to be a different
set of pokes depending on whether its server or client.

A kernel cache has to be invalidated in some important cases. This
is true for modifying things related to the FH or export cache, and
that is already wrapped in an administrative CLI: exportfs.

For gssd, Bruce recently showed me a series of (as far as I know,
undocumented) systemctl commands that are needed to pick up changes
to gssd command line options on RHEL 7.

If I had a lot of time to explore this, my strategy would be:

a) Provide one or a few well-known tools to edit NFS config files

b) Mechanize the acts of putting said edits into effect, and integrate
those mechanisms into the tools

c) Tie the tools directly to documentation (--help or a man page)

Among other benefits, this makes it so much easier for QA folks to
automate tests of configuration adjustments. Also it hides the grimy
details about how the NFS community or the Linux distributor has
implemented these settings, making it easier to modify these
mechanisms without unnecessarily exposing users to change.

I've been encouraging this kind of direction with the nfsidmap
command, for example.


> I would lean towards a flat config file myself, but nfs-utils already
> has code for structured config files, and that code ignores settings
> before the first section.

If there was a library that managed this for us, open-coded config
file parsing for nfsmount.conf and for idmapd.conf in nfs-utils
could be replaced.


--
Chuck Lever



