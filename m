From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: RE: The next step: nfsvers=4
Date: Fri, 20 Mar 2009 11:50:02 -0700
Message-ID: <7A24DF798E223B4C9864E8F92E8C93EC026940A0@SACMVEXC1-PRD.hq.netapp.com>
References: <49C2704F.5050303@RedHat.com> <7A24DF798E223B4C9864E8F92E8C93EC026043D3@SACMVEXC1-PRD.hq.netapp.com> <855593AD-7541-443F-BA92-491EC32FEDFB@oracle.com> <49C28201.1020301@panasas.com> <1FF921B7-4A44-49D7-8E01-1DAC5D18C1AB@oracle.com> <49C382F1.6080205@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Benny Halevy" <bhalevy@panasas.com>,
	"Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
To: "Steve Dickson" <SteveD@redhat.com>,
	"Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47960 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586AbZCTSu0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Mar 2009 14:50:26 -0400
In-Reply-To: <49C382F1.6080205-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 

> -----Original Message-----
> From: Steve Dickson [mailto:SteveD@redhat.com] 
> Sent: Friday, March 20, 2009 4:50 AM
> To: Chuck Lever
> Cc: Benny Halevy; Linux NFS Mailing List
> Subject: Re: The next step: nfsvers=4
> 
> Chuck Lever wrote:
> > If no vers= is specified and only NFSv4 is available on the server, 
> > but something like "nocto" shows up on the command line 
> mount options, do we:
> > 
> > a) fail the mount, or
> > b) ignore the nocto option
> I would say ignore this particular option... since, in a 
> sense, v4 give you this option by default due to 
> delegations... but point well taken... The mapping of
> v3 to v4 and visa versa will have to be addressed... I would 
> guess in the mount command...  
>  
> > 
> > a) seems like the least surprising behavior.
> > 
> > What about "proto=udp" ?  Linux supports UDP for NFSv4, 
> though other 
> > server implementations probably don't.  If that's specified 
> on a mount 
> > command line without a vers= option, what version should we choose?
> I think people just want things to work... so if they specify 
> only UDP and the server supports V4, we give them V4/TCP. If 
> they REALLY want UDP, they would have to specify 'nfsvers=3,udp'.

But, and this is a poor example, they REALLY want v4 and UDP?  There
should be consistency in the way rules are applied.  If specifying
vers=x requires the mount to match version x exactly, then imho, proto=y
should only succeed with protocol y.  There should be a way for the user
to specify exactly what they want, and fail if they can't have it.
Similarly, if someone specifies sec=krb5p, you wouldn't want to fall
back to sec=sys :-)

> 
> Or, if there was an mount configuration file, they could 
> specify the MAX_VERSION to be 3 and then -o udp mounts work 
> as expected...
> 
> > 
> >> For implementing more complex policies, maybe we can extend the 
> >> command syntax to accept a range and/or an ordered list of 
> versions 
> >> to try.
> > 
> > Steve mentioned /etc/default/nfs on Solaris.  I could see 
> > /etc/sysconfig/nfs on Linux containing a couple of lines 
> defining the 
> > range of allowable NFS versions, if we think this is 
> necessary.  This 
> > is a simple pre-existing file, and has little potential for 
> > introducing negative side-effects.
> The /etc/sysconfig/nfs is a distro only file... Meaning I 
> know of only one distro that uses that file.. So I would tend 
> to shy away from putting anything in that... 
> 
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" in the body of a message to 
> majordomo@vger.kernel.org More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
> 
