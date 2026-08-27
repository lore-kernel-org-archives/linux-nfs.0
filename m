Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FB63450F2
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 05:14:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787807661; cv=none; b=scy3q9NcKO03rci0r44ZpWOSKHQaaeS4Q7vNerRFCr0L1b6Sl6hCTJouZBdap26xN/cPgfo6zar5tQcZHUMlSHx6SxHeq0HdjmEHyRdnMIMD/lMYD7zqQndOM2KhifM7ts311LHHEUb6sUCn0EhrUnqFB8sumhszP7iig1NsIGA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787807661; c=relaxed/simple;
	bh=oA8vNi4IsOKN8j/DZtiIDDe5s87lRacRs93CyZU15a4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=qWPI/Xde4GiWvmBalT0hF7iYhP75ad0rEeR4+RlYdwFKkglRKj30EJyMXfKonrgEHdG6UyDorbJ2qinS66QhDLxQkHP6lHcyWeniMJFFOxbynu2TfZZa0Eg2Qpy7SLsE6FUeN5MY7cAepaDqI9NVchgWJg9gsRBJ8+K/6rb4bDg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=Ygn48Pqh; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=LSQvavbw; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="Ygn48Pqh";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="LSQvavbw"
Received: from pps.filterd (m0170393.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67R3HEjh3095678
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 01:14:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=smtpout1; bh=x
	MJa7MqM3OcvKEZNGDHq/YBCg39Q+6UxGYu5nADgXAo=; b=Ygn48PqhWctKnWH3V
	tcIrA68IWtywZXSIdBqe7oCOUYgw/Tz3IfpZ06P3M3YsNWgjAEii21KfHk4ljo08
	8djiTpyGoP03+6cgo+onv5O84LaPv60CLIVXXuxgYOBEZRYlWeLqV7ciTYkTLP3I
	Cg1x9/L3gqZIxXxGl8064dRr+Zb1WlQGEqDuesW+Urp4gICS+ww/x8hW3g0y0a0U
	4T4SmIKAfRpzUWIm/c6ZRU/o4qBSeEbSnu7YGA4dy2xk+VJXiHQbMUUiGC0PsdUk
	cRHRGpRy3VmmM1xrbL1B+3hRBqpwz7Nm/dtOp+wm0+4eifEEwMCOc7DU3Cl4ElA8
	f2/qw==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g773fvf18-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 01:14:19 -0400 (EDT)
Received: from pps.filterd (m0144102.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67R4btjZ3436827
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 01:14:18 -0400
Received: from esapsmtpat02.us.dell.com (esapsmtpat02.us.dell.com [143.166.211.150])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4gaecprakv-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 01:14:17 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787807658; x=1819343658;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=xMJa7MqM3OcvKEZNGDHq/YBCg39Q+6UxGYu5nADgXAo=;
  b=LSQvavbw6rWOQEI1Xe6dDEgniJu7mQ2z2/DcFVEetbH6hPSglOj4EbQu
   HPM3YOuok2GcNu00H0nX2NYBeT5esj8a8AVRDIXPV2y0GOG4KpdgxCBIu
   on/xN9vBqQkHVw2UmTsghE+vFoFUxivp+o/UA2k6sPdMUB5I9l8Z6dADd
   HRI99UFl00UY63W9EyrqRqmpqe93cDsDDooGt7IxqloXN4+zl1LHVVgax
   JHIDUUJaT3Ib/fmjmL5PSIj2f9eMoGhAKN6mCGf6rJCePgHZG8eFUpn7u
   nkDMFLJlFfMXptBEd+VPuYfufDDhprectPszaTMule/fF7zoxghBxwIjR
   Q==;
X-CSE-ConnectionGUID: yKqssG5HS2ufIK6prt4IXA==
X-CSE-MsgGUID: GqHRS4XqTEiwKPAsxwL0yQ==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtpat02.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 27 Aug 2026 05:14:15 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: Chuck Lever <cel@kernel.org>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>,
        Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
        Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
        Tom Talpey <tom@talpey.com>, Rick Macklem <rmacklem@uoguelph.ca>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: release POSIX ACLs of unexecuted compound ops
Date: Thu, 27 Aug 2026 05:14:12 +0000
Message-ID: <20260827051412.5079-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260827045920.4737-1-prabhakar.pujeri@dell.com>
References: <20260823113255.3417-1-prabhakar.pujeri@dell.com> <2805508b-99b1-4bfd-bdd5-cd07ba0789f5@app.fastmail.com> <20260827045920.4737-1-prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-27_02,2026-08-26_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 malwarescore=0 priorityscore=1501 clxscore=1015 adultscore=0 phishscore=0
 lowpriorityscore=0 spamscore=0 impostorscore=0 bulkscore=0 suspectscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608270041
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI3MDA0MCBTYWx0ZWRfX0i0LJBTSXoqn
 u/1g6DMPC4EIgRL77nSbeJJU4auvDIUDKevM3VQf3XhbTgUMt6M0Lh6+x8hEVdQWMHHHQeJmgEL
 fmmOxFWZWjVTbVJNRjiSzO5dXjmZw6p02gCVCM3hyT8N5felHppCMyAXK+koydp8fiEtIf6rqyq
 +tTcRL/1uX3W1QAVJVUCCZSK3JF0zqBnhmHYH4o14l8w/DEBb5f+QNIOxqyRJMgHHYrVgIfcLXf
 LknZMXZ8lhY7WXQTlAgRVF8bLYvHl3tDOm+k8d2BpzzaxkkQ2MEbs/sdiVCjnTEHqs8ksKeblk2
 RzfY+K4OgIMlDswxJ/7rZUlrus/ykDgYhXnbIwL5lXwZWeD9ms+tAiXrS5JvXfezJxQBGUFLeeu
 DfjeZEmsH8Lg0rpUvWkzFs1XA9YLW2cOOWqAKS4T+3M37Dl3VSs1zgu8zYoVo0/4HM+4NVGBYQ8
 SdR6hqRzyuHeMh8r4KQ==
X-Proofpoint-ORIG-GUID: rSTk3tvwTxYJzoeEoOz6F-d19JSdYEte
X-Proofpoint-GUID: rSTk3tvwTxYJzoeEoOz6F-d19JSdYEte
X-Authority-Analysis: v=2.4 cv=CqmPtH4D c=1 sm=1 tr=0 ts=6a8fc7ab cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=i8a7nF7jFa3EbZrjgrQYpA==:17
 a=IkcTkHD0fZMA:10 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=2Lpba0WeoN7BYVdwMO11:22
 a=Q7Pk32MMvI6xH3Y2GMoA:9 a=QEXdDO2ut3YA:10 a=O8hF6Hzn-FEA:10
 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI3MDA0MCBTYWx0ZWRfX47UDdYySpN4p
 fc6B2X3K/T4bgPngr7Y32AFC51uh1oY4N2MebuLfHLIwr44kpC85qhgnNQVfvECpYgKdTnFnfTy
 Qp8lIlxgYuUOtqNZygQ1dwVAcT16sUo=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 suspectscore=0 adultscore=0 spamscore=0 impostorscore=0 clxscore=1015
 bulkscore=0 lowpriorityscore=0 phishscore=0 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608270040

A correction to my description of the runtime-abort case in the
message above:

The invalid PUTFH comes before the ACL-bearing SETATTR. The server
decodes both operations, allocating the POSIX ACL while decoding
SETATTR, then execution stops on the earlier PUTFH before SETATTR runs.
Thus the decoded ACL remains owned by compound-argument cleanup.

The exact NFSv4.2 runtime shape is:

  PUTFH(invalid one-byte filehandle)
  SETATTR(FATTR4_WORD2_POSIX_ACCESS_ACL)

The hard-decode case decodes SETATTR, declares a second operation, and
truncates the request before the second operation number.

Below is the raw-XDR reproducer I used. It defaults to 512 iterations of
each mode; --mode runtime or --mode hard-decode selects one path.

Sorry for the reversed wording in my earlier reply.

-- >8 --
#!/usr/bin/env python3
"""Exercise NFSD cleanup of decoded POSIX ACL attributes.

The runtime-abort request decodes a SETATTR carrying a POSIX access ACL,
then stops while processing an earlier invalid PUTFH.  The hard-decode
request decodes the SETATTR and advertises a second operation whose opnum is
truncated.  Both paths leave the decoded ACL owned by the compound argument
cleanup code.
"""

import argparse
import collections
import random
import socket
import struct


NFS_PROGRAM = 100003
NFS_VERSION = 4
NFSPROC4_COMPOUND = 1
OP_PUTFH = 22
OP_SETATTR = 34
FATTR4_WORD2_POSIX_ACCESS_ACL = 1 << (92 - 64)


def u32(value):
    return struct.pack(">I", value)


def opaque(value):
    padding = b"\0" * ((-len(value)) & 3)
    return u32(len(value)) + value + padding


def access_acl():
    # Minimal valid ACL: user::rwx, group::r-x, other::r-x.
    entries = ((1, 7), (3, 5), (6, 5))
    result = u32(len(entries))
    for tag, permissions in entries:
        result += u32(tag) + u32(permissions) + opaque(b"")
    return result


def setattr():
    attributes = access_acl()
    bitmap = (
        u32(3)
        + u32(0)
        + u32(0)
        + u32(FATTR4_WORD2_POSIX_ACCESS_ACL)
    )
    stateid = b"\0" * 16
    return u32(OP_SETATTR) + stateid + bitmap + opaque(attributes)


def compound(mode):
    header = opaque(b"acl-release-test") + u32(2)
    if mode == "runtime":
        # A one-byte filehandle decodes but fails validation at execution.
        operations = u32(OP_PUTFH) + opaque(b"\0") + setattr()
        return header + u32(2) + operations
    if mode == "hard-decode":
        # opcount says two, but the second operation number is absent.
        return header + u32(2) + setattr()
    raise ValueError(mode)


def rpc_call(xid, body):
    rpc_header = b"".join(
        u32(field)
        for field in (
            xid,
            0,  # CALL
            2,  # RPC version
            NFS_PROGRAM,
            NFS_VERSION,
            NFSPROC4_COMPOUND,
            0,  # AUTH_NONE credential
            0,
            0,  # AUTH_NONE verifier
            0,
        )
    )
    payload = rpc_header + body
    return u32(0x80000000 | len(payload)) + payload


def recv_exact(sock, length):
    chunks = []
    remaining = length
    while remaining:
        chunk = sock.recv(remaining)
        if not chunk:
            raise ConnectionError("server closed the RPC connection")
        chunks.append(chunk)
        remaining -= len(chunk)
    return b"".join(chunks)


def recv_record(sock):
    fragments = []
    while True:
        marker = struct.unpack(">I", recv_exact(sock, 4))[0]
        fragments.append(recv_exact(sock, marker & 0x7FFFFFFF))
        if marker & 0x80000000:
            return b"".join(fragments)


def unpack_u32(data, offset):
    if offset + 4 > len(data):
        raise ValueError("short RPC reply")
    return struct.unpack_from(">I", data, offset)[0], offset + 4


def compound_status(reply, expected_xid):
    xid, offset = unpack_u32(reply, 0)
    message_type, offset = unpack_u32(reply, offset)
    reply_status, offset = unpack_u32(reply, offset)
    if xid != expected_xid or message_type != 1 or reply_status != 0:
        raise ValueError(
            f"unexpected RPC reply header: xid={xid:#x}, "
            f"type={message_type}, status={reply_status}"
        )

    _, offset = unpack_u32(reply, offset)  # verifier flavor
    verifier_length, offset = unpack_u32(reply, offset)
    offset += (verifier_length + 3) & ~3
    accept_status, offset = unpack_u32(reply, offset)
    if accept_status != 0:
        return f"RPC accept status {accept_status}"

    status, _ = unpack_u32(reply, offset)
    return f"NFS4 status {status}"


def run_mode(host, port, timeout, mode, count, first_xid):
    statuses = collections.Counter()
    with socket.create_connection((host, port), timeout=timeout) as sock:
        sock.settimeout(timeout)
        body = compound(mode)
        for sequence in range(count):
            xid = (first_xid + sequence) & 0xFFFFFFFF
            sock.sendall(rpc_call(xid, body))
            statuses[compound_status(recv_record(sock), xid)] += 1
    return statuses


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=2049)
    parser.add_argument("--count", type=int, default=512)
    parser.add_argument("--timeout", type=float, default=5.0)
    parser.add_argument(
        "--mode",
        choices=("runtime", "hard-decode", "both"),
        default="both",
    )
    args = parser.parse_args()

    if args.count < 1:
        parser.error("--count must be positive")

    modes = ("runtime", "hard-decode") if args.mode == "both" else (args.mode,)
    first_xid = random.SystemRandom().randrange(1, 1 << 32)
    for index, mode in enumerate(modes):
        statuses = run_mode(
            args.host,
            args.port,
            args.timeout,
            mode,
            args.count,
            first_xid + index * args.count,
        )
        formatted = ", ".join(
            f"{status}: {seen}" for status, seen in sorted(statuses.items())
        )
        print(f"{mode}: sent {args.count}; {formatted}")


if __name__ == "__main__":
    main()
-- 8< --

--
Prabhakar
