From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Man page update for timeo= and retrans= options.
Date: Mon, 7 Jan 2008 13:15:14 -0500
Message-ID: <BA93E30A-817B-49B9-9703-FC77C2640BA5@oracle.com>
References: <18301.39633.368089.130622@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:11530 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180AbYAGSRH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2008 13:17:07 -0500
In-Reply-To: <18301.39633.368089.130622-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

I just spent two months and rewrote all of nfs(5).  It should appear  
in the next release of nfs-utils.  Steve, when can we expect to see  
the updated man page?

On Jan 3, 2008, at 9:32 PM, Neil Brown wrote:

>
> I've been trying to understand exactly how timeouts work in the NFS
> client and find that the man page in nfs-utils is not correct.
>
> In particular, the implementation differentiates between TCP and UDP,
> while the man page does not make that distinction.
>
> I have attempted an update to the man page as you can see below.  It
> is entirely possible that I have not got it completely correct (or
> comprehensible) so I'm asking for people to check that what I have
> written is correct and clear.
>
> This I would particularly like comment on:
>
> 1/ I have left
>
>  Better overall performance may be achieved by increasing the
>  timeout when mounting on a busy network, to a slow server, or through
>  several routers or gateways.
>
>  unchanged.  Is it still a reasonable thing to say?
>
> 2/ I have moved the documentation about major timeouts into the  
> retrans=
>    section.  Does that break the description up too much?
>
> 3/ the old text seems to say that after the first major-timeout, a
>   slightly different sequence of timeouts are used.  I couldn't find
>   evidence of this in the code.  Did I miss something, or is my text
>   correct?
>
> 4/ Did this change in some ancient kernel version, and should the
>   version number of the change be documented?  e.g. is it a 2.4 / 2.6
>   difference?
>
> 5/ As the behaviour is quite different for UDP and TCP, should we
>   introduce a major_timeo= option which calculates an appropriate
>   retrans= based on the actual timeo= and proto= used.
>
> and anything else that occurs to anyone.
>
> Thanks,
> NeilBrown
>
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index d92da19..0142075 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -83,24 +83,50 @@ Note: Setting this size to a value less than  
> the largest supported
>  block size will adversely affect performance.
>  .TP 1.5i
>  .I timeo=n
> -The value in tenths of a second before sending the
> -first retransmission after an RPC timeout.
> -The default value is 7 tenths of a second.  After the first timeout,
> -the timeout is doubled after each successive timeout until a maximum
> -timeout of 60 seconds is reached or the enough retransmissions
> -have occured to cause a major timeout.  Then, if the filesystem
> -is hard mounted, each new timeout cascade restarts at twice the
> -initial value of the previous cascade, again doubling at each
> -retransmission.  The maximum timeout is always 60 seconds.
> +The value in tenths of a second for the first RPC timeout.  If no
> +reply has been received in this much time, the message is
> +retransmitted.
> +Further timeouts are handled differently depending on the connection
> +type.
> +
> +For UDP (which is unreliable and lacks congestion control),
> +each successive timeout is twice the previous timeout.  As the  
> default
> +is 11 tenths of a seconds, the timeouts used if
> +.I timeo=
> +is not specified are 1.1, 2.2, 4.4, 8.8,... seconds.  The timeout for
> +each retransmission is limited to 60 seconds, so the next few numbers
> +in the above sequence would be 17.6, 35.2, 60, 60.
> +
> +For reliable protocols such as TCP and RDMA, the successive timeouts
> +grow linearly rather than exponentially to a maximum of 10 minutes.
> +The default is 1 minute, so the default successive timeout are 1,
> +2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10 minutes.
> +
> +It is unwise to set
> +.I timeo=
> +explicitly without also setting the protocol to use, as it has a
> +significantly different effect depending on protocol.
> +
>  Better overall performance may be achieved by increasing the
>  timeout when mounting on a busy network, to a slow server, or through
>  several routers or gateways.
>  .TP 1.5i
>  .I retrans=n
>  The number of minor timeouts and retransmissions that must occur  
> before
> -a major timeout occurs.  The default is 3 timeouts.  When a major  
> timeout
> -occurs, the file operation is either aborted or a "server not  
> responding"
> -message is printed on the console.
> +a major timeout occurs.  The default is 2 yielding a total of 3
> +attempts (1 transmission and 2 retransmissions).  When a major  
> timeout
> +occurs the behaviour depends on whether the filesystem was mounted
> +.I hard
> +or
> +.IR soft .
> +In the case of a
> +.I soft
> +mount, the operation will abort and typically return an IO error to
> +the application.  In the case of a
> +.I hard
> +mount a "server not responding" message will be printed on the
> +console, and the request will be retried with the original series of
> +timeouts.
>  .TP 1.5i
>  .I acregmin=n
>  The minimum time in seconds that attributes of a regular file should
> -
> To unsubscribe from this list: send the line "unsubscribe linux- 
> nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



