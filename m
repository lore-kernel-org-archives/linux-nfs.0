Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:41890 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531Ab3F1OsG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jun 2013 10:48:06 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: NFSv4.1 session
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <OF786412D5.F9D839FF-ON88257B97.0077EB71-88257B97.0078C3A8@us.ibm.com>
Date: Fri, 28 Jun 2013 10:47:54 -0400
Cc: "Adam C. Emerson" <aemerson@linuxbox.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Matt W. Benjamin" <matt@linuxbox.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-Id: <18A823DF-68E9-41E4-84D6-F33A0749FC37@oracle.com>
References: <OF8A324DEB.5C9C96EC-ON88257B97.0061DA51-88257B97.0062ED43@us.ibm.com> <1372356342.3365.1.camel@leira.trondhjem.org> <OF72D7519C.7F46B89C-ON88257B97.0063EB30-88257B97.006422E1@us.ibm.com> <1372358524.3365.6.camel@leira.trondhjem.org> <91A474BD-BBB8-42E5-9D09-3536EF02FB9C@oracle.com> <OF786412D5.F9D839FF-ON88257B97.0077EB71-88257B97.0078C3A8@us.ibm.com>
To: Marc Eshel <eshel@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without the HTML this time.

On Jun 27, 2013, at 5:59 PM, Marc Eshel <eshel@us.ibm.com> wrote:

> 
> Chuck Lever <chuck.lever@oracle.com> wrote on 06/27/2013 12:46:30 PM:
> 
> > From: Chuck Lever <chuck.lever@oracle.com> 
> > To: Marc Eshel/Almaden/IBM@IBMUS, 
> > Cc: "Adam C. Emerson" <aemerson@linuxbox.com>, Trond Myklebust 
> > <Trond.Myklebust@netapp.com>, "J. Bruce Fields" 
> > <bfields@redhat.com>, Linux NFS Mailing List <linux-
> > nfs@vger.kernel.org>, "Matt W. Benjamin" <matt@linuxbox.com> 
> > Date: 06/27/2013 12:47 PM 
> > Subject: Re: NFSv4.1 session 
> > 
> > Hi Marc-
> > 
> > On Jun 27, 2013, at 2:42 PM, "Myklebust, Trond" 
> > <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Thu, 2013-06-27 at 11:13 -0700, Marc Eshel wrote:
> > >> 
> > >> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote on 06/27/2013
> > >> 11:05:44 AM:
> > >> 
> > >>> From: "Myklebust, Trond" <Trond.Myklebust@netapp.com> 
> > >>> To: Marc Eshel/Almaden/IBM@IBMUS, 
> > >>> Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "J. 
> > >>> Bruce Fields" <bfields@redhat.com>, "Adam C. Emerson" 
> > >>> <aemerson@linuxbox.com>, "Matt W. Benjamin" <matt@linuxbox.com> 
> > >>> Date: 06/27/2013 11:09 AM 
> > >>> Subject: Re: NFSv4.1 session 
> > >>> 
> > >>> On Thu, 2013-06-27 at 11:00 -0700, Marc Eshel wrote:
> > >>>> Hi Trond, 
> > >>>> 
> > >>>> I am not able to mount from Linux NFS client to the same Ganesha
> > >> NFS
> > >>>> server using multiple IP address. The client was providing the
> > >> same
> > >>>> client-id so the server was using the same session. I tried to
> > >> return
> > >>>> NFS4ERR_CLID_INUSE on the second mount if the target IP is
> > >> different
> > >>>> but the client still did not provide a different client-id like it
> > >>>> should. I am not trying to use trunking I what to have different
> > >>>> server instance for each IP address so I can move that IP between
> > >>>> nodes in the cluster. Any ideas how to accomplish it. 
> > >>>> 
> > >>>> Thanks, Marc.
> > >>> 
> > >>> I don't understand. The client is performing exactly as per design:
> > >> it
> > >>> detects the fact that you are talking to the same server, and so it
> > >>> reuses the same client and session. This is the only sane semantic
> > >> for a
> > >>> NFS client... 
> > >> 
> > >> How is the client detecting that it is the same server? I use a
> > > 
> > > See section 2.10.5.1 of RFC5661.
> > > 
> > >> different IP address on the mount command. Why is the client not
> > >> handling NFS4ERR_CLID_INUSE? 
> > 
> > Is there a section of the spec that prescribes how the client should
> > recover from NFS4ERR_CLID_INUSE? 
> 
> 
> 15.1.13.2.  NFS4ERR_CLID_INUSE (Error Code 10017) 
> 
> 
>   While processing an EXCHANGE_ID operation, the server was presented
>   with a co_ownerid field that matches an existing client with valid
>   leased state, but the principal sending the EXCHANGE_ID operation
>   differs from the principal that established the existing client.
>   This indicates a collision (most likely due to chance) between
>   clients.  The client should recover by changing the co_ownerid and
>   re-sending EXCHANGE_ID (but not with the same slot ID and sequence
>   ID; one or both MUST be different on the re-send).
> 
> When I tried to give it this error it went into an infinite loop trying exchange id again and again. Maybe there is no good why to support it but infinite loop is not good either.

That language looks unimplementable IMO.  I'm looking into it.  I agree that an infinite loop is not correct behavior, and I'll see if that can be addressed.


> I am not trying to make the client support it, I am trying to have a client mount the same fs from two different IP on the same server, and not for the purpose of trunking. I will try to do it by changing server id as described in 2.10.5.1. 
> 
> Thanks, Marc.   
> 
> > 
> > I believe this is not an error that can be recovered from.  The 
> > cases where a clientid is being spoofed are not easily distinguished
> > from cases where it might be safe for a client to try a different 
> > client ID string.
> > 
> > However, note that NFSv4.1 takes a Uniform Client String approach: 
> > an NFSv4.1 client unconditionally uses the same nfs_client_id4.id 
> > string and boot verifier for all servers.  An important reason for 
> > this is that if Transparent State Migration occurs, a destination 
> > server must be able to recognize the client when it connects 
> > expecting its state to be available.
> > 
> > > We only recently changed the client to always use krb5i (or fallback to
> > > AUTH_SYS if krb5i is not available) for EXCHANGE_ID.
> > 
> > -- 
> > Chuck Lever
> > chuck[dot]lever[at]oracle[dot]com
> > 
> > 
> > 
> > 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




