Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44236 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750761AbeCHVfT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Mar 2018 16:35:19 -0500
Date: Thu, 8 Mar 2018 16:35:18 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Guillem Jover <gjover@sipwise.com>
Subject: Re: [Libtirpc-devel] [PATCH] Do not bind to reserved ports
 registered in /etc/services
Message-ID: <20180308213518.GC16485@fieldses.org>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <e18f29cd-639d-be9d-ee93-80df592468db@RedHat.com>
 <20180112184151.GA10261@thunder.hadrons.org>
 <9a53753a-56bf-12b5-f328-ff1f3a72249d@talpey.com>
 <CAFMMQGv03UmmsyXF4BOrwgW9ngpeO=dLjv=Qt=YiPpvgxfo85A@mail.gmail.com>
 <D9BFFDFE-B80F-4220-9A54-F09F882BD0A1@gmail.com>
 <CAFMMQGtt_u19RoCyQAQEaSZRXu3WQ-YSKu4u1BtKtJnaTQbKYw@mail.gmail.com>
 <20180308202423.GA16485@fieldses.org>
 <20180308212600.GB16485@fieldses.org>
 <7FFA3206-9E1D-49AE-A90F-0DFA7A68708F@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7FFA3206-9E1D-49AE-A90F-0DFA7A68708F@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 08, 2018 at 04:28:53PM -0500, Chuck Lever wrote:
> 
> 
> > On Mar 8, 2018, at 4:26 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Thu, Mar 08, 2018 at 03:24:23PM -0500, bfields wrote:
> >> Looks like knfsd's not helpful here, though: the export option
> >> ("secure"/"insecure") defaults to "secure", which always requires a low
> >> port.  It should be easy to modify "secure" to mean "require low ports
> >> only for auth_sys/auth_null", and that's probably the right thing to do.
> > 
> > Disclaimer: totally untested.
> > 
> > --b.
> > 
> > commit ddc2a5f5ce98
> > Author: J. Bruce Fields <bfields@redhat.com>
> > Date:   Thu Mar 8 15:49:48 2018 -0500
> > 
> >    nfsd: don't require low ports for gss requests
> > 
> >    In a traditional NFS deployment using auth_unix, the clients are trusted
> >    to correctly report the credentials of their logged-in users.  The
> >    server assumes that only root on client machines is allowed to send
> >    requests from low-numbered ports, so it can use the originating port
> >    number to distinguish "real" NFS clients from NFS clients run by
> >    ordinary users, to prevent ordinary users from spoofing credentials.
> > 
> >    The originating port number on a gss-authenticated request is less
> >    important.  The authentication ties the request to a user, and we take
> >    it as proof that that user authorized the request.  The low port number
> >    check no longer adds much.
> > 
> >    So, don't enforce low port numbers in the auth_gss case.
> > 
> >    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> Looks plausible to me, and I like the approach.
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Thanks for taking a look.  Also thinking something like this for
exports(5):

--b.

commit 4e3583326c19
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 8 16:32:11 2018 -0500

    exports: document change to "insecure" export option
    
    We're changing the kernel to allow gss requests from high ports even
    when "secure" is set.
    
    If the change gets backported to distro kernels, the kernel version may
    be an imperfect predictor of the behavior, but I think it's the best we
    can do.  I consider the change a bugfix, so hopefully this is OK.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index db47dfdee775..1596fd75578b 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -131,10 +131,12 @@ this way are ro, rw, no_root_squash, root_squash, and all_squash.
 understands the following export options:
 .TP
 .IR secure
-This option requires that requests originate on an Internet port less
-than IPPORT_RESERVED (1024). This option is on by default. To turn it
-off, specify
+This option requires that requests not using gss originate on an
+Internet port less than IPPORT_RESERVED (1024). This option is on by default.
+To turn it off, specify
 .IR insecure .
+(NOTE: older kernels (before upstream kernel version 4.17) enforced this
+requirement on gss requests as well.)
 .TP
 .IR rw
 Allow both read and write requests on this NFS volume. The
