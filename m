From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS4ERR_RESOURCE returns Remote IO Error
Date: Fri, 11 Sep 2009 08:33:53 -0400
Message-ID: <1252672433.20283.16.camel@heimdal.trondhjem.org>
References: <4AAA0063.4070406@bfh.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: =?ISO-8859-1?Q?Andr=E9?= Roth <andre.roth-omB+W0Dpw2o@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbZIKMeN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2009 08:34:13 -0400
In-Reply-To: <4AAA0063.4070406-omB+W0Dpw2o@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-09-11 at 09:46 +0200, Andr=C3=A9 Roth wrote:
> Hello list,
>=20
> We have a problem with the NFS client on Linux on a NetApp filer. Eve=
ry
> now and then we are getting huge amounts of "Remote IO Errors" on the
> mounted home directories. This is new, we had no problems with the sa=
me
> setup some months ago.
>=20
> The reason for the Remote IO Errors is that the server is returning a=
n
> NFS4ERR_RESOURCE error, even just for
> a simple "touch foo". The tcpdump of such a touch command I have list=
ed
> below.
>=20
> I suspect that maybe the deduplication or backup operation make the
> filer "busy" so it cannot respond to all compound operations.
>=20
> I've seen that linux NFS just passes this error to the user as
> EREMOTEIO. OpenSolaris seems to delay and retry. According to the RFC
> I'm not sure what would be the right thing to do. But I think this is
> meant to be a temporary error, and an NFS client should, in the examp=
le
> below, take the first two operations as completed, and retry the
> remaining 5 ones, or maybe retry the whole compound message.
>=20
> What is your insight on this error ?
> Is there something I can try, like returning EAGAIN and see if the er=
ror
> gets handled correctly ?
> The problem ocurred one or twice a week, without any regularity..

This has been discussed extensively on the IETF mailing lists, and the
code therefore reflects our current understanding of RFC3530.

Unlike NFS4ERR_DELAY, the error NFS4ERR_RESOURCE is not listed as a
temporary error, nor is there any admonition in the RFC to retry or
should do anything other than to split up a possible overly-complex
COMPOUND (which is usually not possible for us). To quote:

   In the processing of the COMPOUND procedure, the server may find
   that it does not have the available resources to execute any or all
   of the operations within the COMPOUND sequence.  In this case, the
   error NFS4ERR_RESOURCE will be returned for the particular operation
   within the COMPOUND procedure where the resource exhaustion
   occurred.  This assumes that all previous operations within the
   COMPOUND sequence have been evaluated successfully.  The results for
   all of the evaluated operations must be returned to the client.

IOW: If dedup is causing the filer to start returning NFS4ERR_RESOURCE
errors to the client, then that would appear to be a serious server bug=
=2E
I'd suggest you contact your NetApp sales rep, and ask them to help you
escalate this so that it gets due attention.

Cheers,
  Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
