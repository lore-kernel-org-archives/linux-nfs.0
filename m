Return-Path: SteveD@redhat.com
Message-ID: <5462608B.1090607@RedHat.com>
Date: Tue, 11 Nov 2014 14:16:27 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Benjamin Coddington <bcodding@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>
In-Reply-To: <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>



On 11/11/2014 10:01 AM, Trond Myklebust wrote:
> One thing you should note when doing this: the current parser for
> /etc/nfsmount.conf does not support minor versions. I think it needs
> to, so that we can continue to use it to set defaults.
Well setting Nfsvers=4.1 will give you a v4.1 mounts (assuming
the server supports v4.1. but setting Defaultvers=4.1 does
give you a v4.0 mount, which will need to be fixed.

> 
> ...and to answer your questions above, I think that we should be able
> to specify a 'default nfsv4 minor version' in /etc/nfsmount.conf, and
> then negotiate down from there.
> IOW: extend the 'Defaultvers' and 'Nfsvers' options to support 4.0,
> 4.1, 4.2,....
Well Defaultvers is a negotiation with the server, Nfsvers is not. 
So when Nfsvers set set there is no  negotiation, they get what is
set to (aka 3, 4, 4.0, 4.1, just like the command line).

With  Defaultvers its a negotiation so set it to highest
version and let it go... I'm not sure we need another
variable to complicate things...   

> 
> The result should be that If I do 'mount -t nfs' with no '-overs'
> option, then we start at 4.1 (if that is the default in
> /etc/nfsmount.conf) and then try 4.0, 3, 2 in that order.
> If I do 'mount -t nfs -overs=4', then again consult /etc/nfsmount.conf;
> - if there is a default matching a v4 minor version, then start at
> that and negotiate down (but stop at 4.0).
Again, I'm thinking this type of  complexity is not needed (especially 
from a testing matrix point of view). 

besides, if someone is specifying a version on the command line, is most likely
they are not going to be using /etc/nfsmount.conf as all... 
  
> - if there is no default in /etc/nfsmount.conf, then perhaps assume a
> default of 0(????)
I'm thinking why not default to the better minor version?? 4.1 => 4.0 => 3


steved.
