Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1223 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750889Ab1KBXFV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 19:05:21 -0400
Subject: Re: GSSAPI Proxy initiative
From: Simo Sorce <simo@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: krbdev <krbdev@mit.edu>, Andy Adamson <andros@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Nico Williams <nico@cryptonector.com>,
        Kevin Coffman <kwc@citi.umich.edu>, Bruce Fields <bfields@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>, Greg Hudson <ghudson@mit.edu>,
        Tom Yu <tlyu@mit.edu>, Sam Hartman <hartmans@mit.edu>
In-Reply-To: <1320269170.7734.585.camel@willson.li.ssimo.org>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Nov 2011 19:05:15 -0400
Message-ID: <1320275115.7734.595.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Forgot a footnote. See at the end.

On Wed, 2011-11-02 at 17:26 -0400, Simo Sorce wrote:
> Hello everyone,
> you are all CCed because you either expressed interested, are already
> involved with or may be affected/interested in this initiative.
> 
> At the recent MIT Kerberos Conference there has been some renewed
> interested in a concept that has surfaced in GSSAPI related circles a
> few times. That of building a GSSAPI Proxy to allow separation of
> privileges between applications and key handling.
> 
> There are various stakeholders that would like to have a solution in
> this areas for various reasons:
> 
> == Privilege separation ==
> 
> One of the needs that GSSAPI Proxy is able to address is separation of
> privileges. Initiating/accepting is delegated to the GSSAPI Proxy so
> that applications do not have direct access to the key material. This
> helps to avoid exposing keys when network facing applications are
> compromised. On some OSs Mandatory Access Control will help keep those
> keys secure if they are not directly accessible to the applications.
> 
> 
> == Kernel Network File Systems ==
> 
> There are a number of file systems implemented in kernel and especially
> NFS that uses gss-krb5 to negotiate security over the network.
> 
> Most implementations use a gssd daemon in user space to handle
> accepting/initiating. In particular in the Linux kernel a few people
> feel that the current implementation is sub-optimal and would like to
> improve it. The functionality needed by the kernel is pretty similar to
> that needed to proxy gssapi for other apps, so it seem like a good idea
> to unify these implementations, or at least use a common protocol so
> that the same implementation can be used if OS vendors/Integrators want
> to do so.
> 
> 
> == PAC/PAD verification ==
> 
> When using Kerberos applications can receive tickets that contain a
> MS-PAC or (in future) a PAD*.
> In some scenarios we want to use the PAC to synthesize a user on the
> target system so that it can create and access files and other
> resources. A PAC/PAD is very useful for file servers for example because
> it can standardize how identities are retrieved w/o forcing file server
> developers to mess with protocols like LDAP and other amenities.
> 
> These structures are signed with service keys, the same keys apps have
> currently access to. If key material is left accessible to apps it means
> a compromised application could create a PAC/PAD to attempt privilege
> escalation by injecting this data in the system.
> 
> Although these structures are also signed with a KDC key, it would be
> very expensive to require a roundtrip to the KDC to ask for
> verification. It would also make the server reliant on KDC availability
> which is normally not required for kerberos based auth after the ticket
> is acquired.
> 
> 
> == SSH credential forwarding ? ==
> 
> Currently, when using GSSAPI in conjunction with SSH, credentials are
> made available to the remote end by simply copying them over and thus
> giving the remote host direct access to the user creds. Quite a few
> people would prefer to use a ssh-agent like approach instead where
> credentials stay always on the local machine and context establishment
> is proxied over the ssh channel. Although this initiative will *not*
> address this feature, we'd like to build the protocol in such a way that
> it will become easy to implement this mechanism in the future.
> 
> 
> 
> ==== Current status ====
> 
> I am trying to push this initiative and I am organizing and contacting
> people to enter the planning phase. I have received initial availability
> from some stakeholders in helping to shape this initiative from protocol
> design to transport/interface (esp. against the kernel) design,
> implementation, testing, etc..
> 
> Because there are many parties involved I would like to try to keep this
> discussion focused as much as possible to the proxy functionality.
> 
> I see this effort involving mainly 3 areas at this stage.
> 
> 1) design of the protocol
> 
>         I this area I had some preliminary discussion with some of the
>         people that are interested in the effort. Due to availability in
>         both kernel and user space implementation is seem like an
>         ONC/RPC - XDR based protocol is the best common denominator and
>         easily implementable by all parties.
>         Nothing is set in stone yet, any idea is welcome.
>         
> 2) kernel and user space interfaces to the GSSAPI Proxy Daemon
> 
>         For user-space to user-space communication is seem clear that a
>         unix socket is probably the more natural transport to use.
>         
>         From the Linux kernel side deciding on the right upcall
>         mechanism seem not as straight forward. One option seem to be
>         the netlink or rather the connector interface that is layered on
>         top of it. More discussion is definitely needed on this front.
> 
> 3) Changes to libgssapi to implement transparent proxying for user space
> applications
> 
>         Some high level ideas have been floating around on where to hook
>         this proxy layer in libgssapi but it is all in the air for now.
>         Ideas here are very welcome.
> 
> 
> Additional areas involve the design of the daemon in terms of
> scalability, access control and various security considerations,
> portability (?), etc...
> 
> 
> 
> Any feedback is welcome esp. if you have valuable ideas on the design
> issues.
> We will probably keep cross-posting a bit so that we can involve all
> possible stakeholders, going forward we'll find a way to refocus
> discussions around a few forums depending on what part of the problem
> people is working on.
> If you know other people/lists that should be involved, please feel free
> to forward and include them in the discussion.
> 
> 
> Regards,
> Simo.


*PAD: Stands for Principal Authorization Data,
see: http://tools.ietf.org/html/draft-ietf-krb-wg-general-pac-01.html

-- 
Simo Sorce * Red Hat, Inc * New York

