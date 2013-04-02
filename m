Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:47594 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1760526Ab3DBNPG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2013 09:15:06 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Tue, 02 Apr 2013 09:15:05 -0400
From: David Quigley <dpquigl@davequigley.com>
To: "Vu, Joseph" <joseph.vu@boeing.com>
Cc: Casey Schaufler <casey@schaufler-ca.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <steved@redhat.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: RE: [PATCH 13/14] NFSD: Server implementation of MAC Labeling
In-Reply-To: <756D04455A661C4CA25DC5BA4902A7A722698BD4@XCH-PHX-204.sw.nos.boeing.com>
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
 <1364478845-29796-14-git-send-email-SteveD@redhat.com>
 <20130328161444.GF7080@fieldses.org> <51550C03.1000107@davequigley.com>
 <20130329144050.GB22307@fieldses.org>
 <001ff69afd411b0318d7122bf07bd218@countercultured.net>
 <5155B0E3.9040108@schaufler-ca.com> <20130329184219.GG22307@fieldses.org>
 <5155F51E.8020603@schaufler-ca.com>
 <756D04455A661C4CA25DC5BA4902A7A722698B22@XCH-PHX-204.sw.nos.boeing.com>
 <b226f82606306e86ffaede6909512e6d@countercultured.net>
 <756D04455A661C4CA25DC5BA4902A7A722698BD4@XCH-PHX-204.sw.nos.boeing.com>
Message-ID: <b6420854e9df99c00632d0c9af85bc08@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/02/2013 09:01, Vu, Joseph wrote:
> Thank you David.
>
> It is good that the community at least support some short term 
> solution.
> Labeled NFS has been working hard to get the community acceptance.
>
> Thanks.
>
>
> -----Original Message-----
> From: David Quigley [mailto:dpquigl@davequigley.com]
> Sent: Monday, April 01, 2013 10:55 AM
> To: Vu, Joseph
> Cc: Casey Schaufler; J. Bruce Fields; Steve Dickson; Trond Myklebust;
> J. Bruce Fields; David P. Quigley; Linux NFS list; Linux Security
> List; SELinux List
> Subject: RE: [PATCH 13/14] NFSD: Server implementation of MAC 
> Labeling
>
> On 04/01/2013 08:54, Vu, Joseph wrote:
>
>> What is a good, and working alternative for NFS in term of SE label?
>
> There isn't any unless you want to start a labeled cifs project. We
> looked at CIFS and NFSv4 back when I started this project and from
> what we saw NFS had the more open community. There are other 
> solutions
> but they are not ideal. I believe someone did SELinux labels on
> network attached storage by treating the NAS as an iSCSI device. This
> isn't ideal because it has concurrency issues. Someone proposed xattr
> for
> NFSv4/NFSv3 support and that was shot down as well (and for good
> reason). I don't share Casey's skepticism about the long term
> importance of NFS. I think with NFSv4 and all the work that has gone
> into it we'll see NFS being important in Linux and enterprises for a
> very long time to come.


I don't consider this a short term solution. Labeled NFS is a long term 
solution with short term milestones that get us something working fairly 
quickly and I mean fairly quickly in IETF terms (about 5 years). I don't 
buy Casey's assessment that network file-system protocols are old school 
and on the way out. A number of storage vendors are doing lots of real 
work into new versions of NFS and CIFS and they are major technologies 
in enterprise storage. To be honest I can't even figure out what sort of 
"long term" solutions Casey is talking about. It looks like he strung 
together a bunch a buzz words together into some vague ephemeral 
concept. Typing his idea of future storage into Google doesn't really 
come up with anything substantive either.
