Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:41731 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab2JXQKN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 12:10:13 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so717768vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 09:10:09 -0700 (PDT)
Date: Wed, 24 Oct 2012 12:10:04 -0400
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RPC Race Condition
Message-ID: <20121024161004.GF27191@nyc-qws-132.nyc.delacy.com>
References: <20121022202611.GA27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928AB39@SACEXCMBX04-PRD.hq.netapp.com>
 <20121023134551.GB27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928C74A@SACEXCMBX04-PRD.hq.netapp.com>
 <20121023200855.GC27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928DCDD@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024124047.GD27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928F571@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024142333.GE27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928F920@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90928F920@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Oct 24, 2012 at 02:56:55PM +0000, Myklebust, Trond wrote:
> OK, I've now posted the patches in the "bugfixes" branch of
> 
>        git://git.linux-nfs.org/projects/trondmy/linux-nfs.git

Cool, I'll try to get that pulled, compiled and tested by the end of the
day.

> 
> By the way, you said that you were using a set of systemtap scripts to debug these races? If you'd be OK sharing those scripts, I'd love to see them. Debugging this kind of race is always difficult...
> 

Sure.  Attached are a bunch of them.  They have very unhelpful names. :)

They progressively get more involved.  As I watched their output coupled
with reading the source code, I found new areas I wanted to explore.

The numbered scripts are all aimed at being run with the `-x' flag
pointed at the process doing the stat calls, i.e.:

# stap 1.stp -x $(pgrep hang.py)

The `rpciod.stp' script is just meant to be run without any
qualifications to trace the function calls rpciod is making, i.e.:

# stap rpciod.stp

The script that really allowed me to see the race condition was 14.stp.
It produces a lot of output to poke through, but here is basically what
its doing:

  - At the top there are a lot of helper functions.  Their basic goals
    are to translate from numbers to human readable strings.  I.e.
    instead of seeing `xs_tcp_send_request' return 0xffffffffffffffe0, I
    wanted to see EPIPE.  It makes it a lot easier to pour over several
    pages of output while testing.

  - Below that there are the actual probes for the functions we want to
    trace, the gist of which is:

    - It watches for a call to `__rpc_execute' for the process id we're
      interested in.  Once it fires, we use the address of its
      task_struct to mark it as being traced via the `trace' array.

    - This probe also takes the address of the `struct rpc_task' we're
      currently working with and marks it as being traced via the
      `task_trace' array.  The idea with this is that another one of our
      probes enables tracing of `rpc_make_runnable' and on entry into
      that call we make sure we're tracing that task.  This way we can
      catch wake up calls for the task we care about.  When we do, we
      print that fact and a stack backtrace of how we got there.

    - There are many other functions that I ask to trace, but only if
      we're tracing the main task via the address of its task_struct
      being a valid key in the `trace' array.

    - I do something similiar to tracing calls to `rpc_make_runnable' with
      sockets.  Here we record the `struct sock' address in
      `xs_tcp_send_request'.  In another probe we enable tracing of
      `tcp_set_state' but only for the `struct sock' that we care about.

I'm far from a SystemTap expert, and some of this stuff might not be
particularly safe (i.e. if I'm trying to translate tk_runstate to a
human readable string while something else is updating it on another
CPU).  But it all seemed to work "well enough" and give insight into
what was actually happening.

Here is an example snippet of some of the output produced with 14.stp:
-----8<-----
1351091111259227075 [0xffff88060b27d540]    150 hang.py(5560):  -> call_transmit: task: tk_status: 0, tk_runstate: RPC_TASK_RUNNING|RPC_TASK_ACTIVE, parms: task=0xffff8806355c9080
1351091111259235702 [0xffff88060b27d540]    159 hang.py(5560):   -> xs_tcp_send_request: sock: sock=0xffff880620803140, state: SS_CONNECTING, sk=0xffff880635ded540, sk_state: TCP_ESTABLISHED, sk_err: 0, sk_shutdown: 0, task: tk_status: 0, tk_runstate: RPC_TASK_RUNNING|RPC_TASK_ACTIVE, parms: task=0xffff8806355c9080
1351091111259253562 [0xffff88060b27d540]    177 hang.py(5560):   <- xs_tcp_send_request: 0
1351091111259258719 [0xffff88060b27d540]    182 hang.py(5560):   -> call_transmit_status: task: tk_status: 0, tk_runstate: RPC_TASK_RUNNING|RPC_TASK_QUEUED|RPC_TASK_ACTIVE, parms: task=0xffff8806355c9080
1351091111259264704 [0xffff88060b27d540]    188 hang.py(5560):   <- call_transmit_status:
1351091111259267273 [0xffff88060b27d540]    190 hang.py(5560):  <- call_transmit:
1351091111259270415 [0xffff88060b27d540]    193 hang.py(5560):  -> out_of_line_wait_on_bit: word: tk_runstate: RPC_TASK_QUEUED|RPC_TASK_ACTIVE, parms: word=0xffff8806355c90f0 bit=0x1 action=0xffffffffa042f930 mode=0x82
1351091111259276940 [0xffff88060b27d540]    200 hang.py(5560):   -> rpc_wait_bit_killable: parms: word=0xffff8806355c90f0
1351091117489543178 [0xffff880637daeaa0] swapper -> rpc_make_runnable: task: tk_status: EAGAIN, tk_runstate: RPC_TASK_QUEUED|RPC_TASK_ACTIVE, parms: task=0xffff8806355c9080
 0xffffffffa042f840 : rpc_make_runnable+0x0/0x80 [sunrpc]
 0xffffffffa042fb5e : rpc_wake_up_task_queue_locked+0x18e/0x270 [sunrpc]
 0xffffffffa042fc8e : rpc_wake_up_status+0x4e/0x80 [sunrpc]
 0xffffffffa04288ec : xprt_wake_pending_tasks+0x2c/0x30 [sunrpc]
 0xffffffffa042b9fd : xs_error_report+0x4d/0x90 [sunrpc]
 0xffffffff8148d629 : tcp_reset+0x59/0x70 [kernel]
 0xffffffff8148d918 : tcp_validate_incoming+0x2d8/0x3a0 [kernel]
 0xffffffff81491006 : tcp_rcv_established+0x2e6/0x800 [kernel]
 0xffffffff814990f3 : tcp_v4_do_rcv+0x2e3/0x430 [kernel]
 0xffffffff8149a96e : tcp_v4_rcv+0x4fe/0x8d0 [kernel]
 0xffffffff8147868d : ip_local_deliver_finish+0xdd/0x2d0 [kernel]
 0xffffffff81478918 : ip_local_deliver+0x98/0xa0 [kernel]
 0xffffffff81477ddd : ip_rcv_finish+0x12d/0x440 [kernel]
 0xffffffff81478365 : ip_rcv+0x275/0x350 [kernel]
 0xffffffff81441a5b : __netif_receive_skb+0x49b/0x6f0 [kernel]
 0xffffffff81443cd8 : netif_receive_skb+0x58/0x60 [kernel]
 0xffffffff81443de0 : napi_skb_finish+0x50/0x70 [kernel]
 0xffffffff81446319 : napi_gro_receive+0x39/0x50 [kernel]
 0xffffffffa0126f2f [bnx2]
 0x0 (inexact)
-----8<-----

Chris

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="1.stp"

global trace

probe module("sunrpc").function("rpc_call_sync").call {
    if (pid() == target()) {
        t = task_current()
        printf("[0x%x] %s -> %s: %s\n", t, thread_indent(1), probefunc(), $$parms)
        trace[t] = 1
    }
}

probe module("sunrpc").function("rpc_call_sync").return {
    t = task_current()
    if (trace[t]) {
        printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), $$return)
        trace[t] = 0
    }
}

probe module("sunrpc").function("*").call {
    t = task_current()
    if (trace[t]) {
        printf("[0x%x] %s -> %s: %s\n", t, thread_indent(1), probefunc(), $$parms)
    }
}

probe module("sunrpc").function("*").return {
    t = task_current()
    if (trace[t]) {
        printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), $$return)
    }
}

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="3.stp"

# vim: ts=2 sts=2 sw=2 et

global trace

probe module("sunrpc").function("__rpc_execute").call {
  t = task_current()
  if (pid() == target()) {
    printf("[0x%x] %s -> %s: %s\n", t, thread_indent(1), probefunc(), $$parms)
    trace[t] = 1
  }
}

probe module("sunrpc").function("__rpc_execute").return {
  t = task_current()
  if (trace[t]) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), $$return)
    trace[t] = 0
  }
}

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="5.stp"

global trace

probe module("sunrpc").function("__rpc_execute").call {
  if (pid() == target()) {
    t = task_current()
    proc = @cast(&$task->tk_msg, "struct rpc_message")->rpc_proc
    func = @cast(proc, "struct rpc_procinfo")->p_name
    serv = @cast($task->tk_client, "struct rpc_clnt")->cl_server
    func_name = kernel_string(func)
    serv_name = kernel_string(serv)
    printf("[0x%x] %s -> %s: %s: proc_name: %s, server: %s\n", t, thread_indent(1), probefunc(), $$parms, func_name, serv_name)
    trace[t] = 1
  }
}

probe module("sunrpc").function("__rpc_execute").return {
  t = task_current()
  if (trace[t]) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), $$return)
    trace[t] = 0
  }
}

probe module("sunrpc").function("*").call {
  t = task_current()
  if (trace[t]) {
      printf("[0x%x] %s -> %s: %s\n", t, thread_indent(1), probefunc(), $$parms)
  }
}

probe module("sunrpc").function("*").return {
  t = task_current()
  if (trace[t]) {
      printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), $$return)
  }
}

# vim: ts=2 sts=2 sw=2 et

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="7.stp"

global trace

global _errno[134]

probe begin {
  _errno[0] = "0"
  _errno[1] = "EPERM"
  _errno[2] = "ENOENT"
  _errno[3] = "ESRCH"
  _errno[4] = "EINTR"
  _errno[5] = "EIO"
  _errno[6] = "ENXIO"
  _errno[7] = "E2BIG"
  _errno[8] = "ENOEXEC"
  _errno[9] = "EBADF"
  _errno[10] = "ECHILD"
  _errno[11] = "EAGAIN"
  _errno[12] = "ENOMEM"
  _errno[13] = "EACCES"
  _errno[14] = "EFAULT"
  _errno[15] = "ENOTBLK"
  _errno[16] = "EBUSY"
  _errno[17] = "EEXIST"
  _errno[18] = "EXDEV"
  _errno[19] = "ENODEV"
  _errno[20] = "ENOTDIR"
  _errno[21] = "EISDIR"
  _errno[22] = "EINVAL"
  _errno[23] = "ENFILE"
  _errno[24] = "EMFILE"
  _errno[25] = "ENOTTY"
  _errno[26] = "ETXTBSY"
  _errno[27] = "EFBIG"
  _errno[28] = "ENOSPC"
  _errno[29] = "ESPIPE"
  _errno[30] = "EROFS"
  _errno[31] = "EMLINK"
  _errno[32] = "EPIPE"
  _errno[33] = "EDOM"
  _errno[34] = "ERANGE"
  _errno[35] = "EDEADLK"
  _errno[36] = "ENAMETOOLONG"
  _errno[37] = "ENOLCK"
  _errno[38] = "ENOSYS"
  _errno[39] = "ENOTEMPTY"
  _errno[40] = "ELOOP"
  _errno[41] = "UNDEF"
  _errno[42] = "ENOMSG"
  _errno[43] = "EIDRM"
  _errno[44] = "ECHRNG"
  _errno[45] = "EL2NSYNC"
  _errno[46] = "EL3HLT"
  _errno[47] = "EL3RST"
  _errno[48] = "ELNRNG"
  _errno[49] = "EUNATCH"
  _errno[50] = "ENOCSI"
  _errno[51] = "EL2HLT"
  _errno[52] = "EBADE"
  _errno[53] = "EBADR"
  _errno[54] = "EXFULL"
  _errno[55] = "ENOANO"
  _errno[56] = "EBADRQC"
  _errno[57] = "EBADSLT"
  _errno[58] = "UNDEF"
  _errno[59] = "EBFONT"
  _errno[60] = "ENOSTR"
  _errno[61] = "ENODATA"
  _errno[62] = "ETIME"
  _errno[63] = "ENOSR"
  _errno[64] = "ENONET"
  _errno[65] = "ENOPKG"
  _errno[66] = "EREMOTE"
  _errno[67] = "ENOLINK"
  _errno[68] = "EADV"
  _errno[69] = "ESRMNT"
  _errno[70] = "ECOMM"
  _errno[71] = "EPROTO"
  _errno[72] = "EMULTIHOP"
  _errno[73] = "EDOTDOT"
  _errno[74] = "EBADMSG"
  _errno[75] = "EOVERFLOW"
  _errno[76] = "ENOTUNIQ"
  _errno[77] = "EBADFD"
  _errno[78] = "EREMCHG"
  _errno[79] = "ELIBACC"
  _errno[80] = "ELIBBAD"
  _errno[81] = "ELIBSCN"
  _errno[82] = "ELIBMAX"
  _errno[83] = "ELIBEXEC"
  _errno[84] = "EILSEQ"
  _errno[85] = "ERESTART"
  _errno[86] = "ESTRPIPE"
  _errno[87] = "EUSERS"
  _errno[88] = "ENOTSOCK"
  _errno[89] = "EDESTADDRREQ"
  _errno[90] = "EMSGSIZE"
  _errno[91] = "EPROTOTYPE"
  _errno[92] = "ENOPROTOOPT"
  _errno[93] = "EPROTONOSUPPORT"
  _errno[94] = "ESOCKTNOSUPPORT"
  _errno[95] = "EOPNOTSUPP"
  _errno[96] = "EPFNOSUPPORT"
  _errno[97] = "EAFNOSUPPORT"
  _errno[98] = "EADDRINUSE"
  _errno[99] = "EADDRNOTAVAIL"
  _errno[100] = "ENETDOWN"
  _errno[101] = "ENETUNREACH"
  _errno[102] = "ENETRESET"
  _errno[103] = "ECONNABORTED"
  _errno[104] = "ECONNRESET"
  _errno[105] = "ENOBUFS"
  _errno[106] = "EISCONN"
  _errno[107] = "ENOTCONN"
  _errno[108] = "ESHUTDOWN"
  _errno[109] = "ETOOMANYREFS"
  _errno[110] = "ETIMEDOUT"
  _errno[111] = "ECONNREFUSED"
  _errno[112] = "EHOSTDOWN"
  _errno[113] = "EHOSTUNREACH"
  _errno[114] = "EALREADY"
  _errno[115] = "EINPROGRESS"
  _errno[116] = "ESTALE"
  _errno[117] = "EUCLEAN"
  _errno[118] = "ENOTNAM"
  _errno[119] = "ENAVAIL"
  _errno[120] = "EISNAM"
  _errno[121] = "EREMOTEIO"
  _errno[122] = "EDQUOT"
  _errno[123] = "ENOMEDIUM"
  _errno[124] = "EMEDIUMTYPE"
  _errno[125] = "ECANCELED"
  _errno[126] = "ENOKEY"
  _errno[127] = "EKEYEXPIRED"
  _errno[128] = "EKEYREVOKED"
  _errno[129] = "EKEYREJECTED"
  _errno[130] = "EOWNERDEAD"
  _errno[131] = "ENOTRECOVERABLE"
  _errno[132] = "ERFKILL"
  _errno[133] = "EHWPOISON"
}

function err_num2str:string (error:long) {
  error = -error
  return (error in _errno ? _errno[error] : sprintf("0x%x", -error))
}

probe module("sunrpc").function("__rpc_execute").call {
  if (pid() == target()) {
      t = task_current()
      p = probefunc()
      serv      = @cast($task->tk_client, "struct rpc_clnt")->cl_server
      serv_name = kernel_string(serv)
      proc      = @cast(&$task->tk_msg, "struct rpc_message")->rpc_proc
      func      = @cast(proc, "struct rpc_procinfo")->p_name
      func_name = kernel_string(func)
      printf("[0x%x] %s -> %s: func: %s, server: %s, parms: %s\n", t, thread_indent(1), p, func_name, serv_name, $$parms)
      trace[t] = 1
  }
}

probe module("sunrpc").function("__rpc_execute").return {
  t = task_current()
  p = probefunc()
  if (trace[t]) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), p, $$return)
    trace[t] = 0
  }
}

probe module("sunrpc").function("xs_tcp_send_request").call {
  t = task_current()
  p = probefunc()
  if (trace[t]) {
    printf("[0x%x] %s -> %s: %s\n", t, thread_indent(1), p, $$parms)
  }
}

probe module("sunrpc").function("xs_tcp_send_request").return {
  t = task_current()
  if (trace[t]) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), err_num2str($return))
  }
}

# vim: ts=2 sts=2 sw=2 et

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="8.stp"

global trace

global _errno[134]

probe begin {
  _errno[0] = "0"
  _errno[1] = "EPERM"
  _errno[2] = "ENOENT"
  _errno[3] = "ESRCH"
  _errno[4] = "EINTR"
  _errno[5] = "EIO"
  _errno[6] = "ENXIO"
  _errno[7] = "E2BIG"
  _errno[8] = "ENOEXEC"
  _errno[9] = "EBADF"
  _errno[10] = "ECHILD"
  _errno[11] = "EAGAIN"
  _errno[12] = "ENOMEM"
  _errno[13] = "EACCES"
  _errno[14] = "EFAULT"
  _errno[15] = "ENOTBLK"
  _errno[16] = "EBUSY"
  _errno[17] = "EEXIST"
  _errno[18] = "EXDEV"
  _errno[19] = "ENODEV"
  _errno[20] = "ENOTDIR"
  _errno[21] = "EISDIR"
  _errno[22] = "EINVAL"
  _errno[23] = "ENFILE"
  _errno[24] = "EMFILE"
  _errno[25] = "ENOTTY"
  _errno[26] = "ETXTBSY"
  _errno[27] = "EFBIG"
  _errno[28] = "ENOSPC"
  _errno[29] = "ESPIPE"
  _errno[30] = "EROFS"
  _errno[31] = "EMLINK"
  _errno[32] = "EPIPE"
  _errno[33] = "EDOM"
  _errno[34] = "ERANGE"
  _errno[35] = "EDEADLK"
  _errno[36] = "ENAMETOOLONG"
  _errno[37] = "ENOLCK"
  _errno[38] = "ENOSYS"
  _errno[39] = "ENOTEMPTY"
  _errno[40] = "ELOOP"
  _errno[41] = "UNDEF"
  _errno[42] = "ENOMSG"
  _errno[43] = "EIDRM"
  _errno[44] = "ECHRNG"
  _errno[45] = "EL2NSYNC"
  _errno[46] = "EL3HLT"
  _errno[47] = "EL3RST"
  _errno[48] = "ELNRNG"
  _errno[49] = "EUNATCH"
  _errno[50] = "ENOCSI"
  _errno[51] = "EL2HLT"
  _errno[52] = "EBADE"
  _errno[53] = "EBADR"
  _errno[54] = "EXFULL"
  _errno[55] = "ENOANO"
  _errno[56] = "EBADRQC"
  _errno[57] = "EBADSLT"
  _errno[58] = "UNDEF"
  _errno[59] = "EBFONT"
  _errno[60] = "ENOSTR"
  _errno[61] = "ENODATA"
  _errno[62] = "ETIME"
  _errno[63] = "ENOSR"
  _errno[64] = "ENONET"
  _errno[65] = "ENOPKG"
  _errno[66] = "EREMOTE"
  _errno[67] = "ENOLINK"
  _errno[68] = "EADV"
  _errno[69] = "ESRMNT"
  _errno[70] = "ECOMM"
  _errno[71] = "EPROTO"
  _errno[72] = "EMULTIHOP"
  _errno[73] = "EDOTDOT"
  _errno[74] = "EBADMSG"
  _errno[75] = "EOVERFLOW"
  _errno[76] = "ENOTUNIQ"
  _errno[77] = "EBADFD"
  _errno[78] = "EREMCHG"
  _errno[79] = "ELIBACC"
  _errno[80] = "ELIBBAD"
  _errno[81] = "ELIBSCN"
  _errno[82] = "ELIBMAX"
  _errno[83] = "ELIBEXEC"
  _errno[84] = "EILSEQ"
  _errno[85] = "ERESTART"
  _errno[86] = "ESTRPIPE"
  _errno[87] = "EUSERS"
  _errno[88] = "ENOTSOCK"
  _errno[89] = "EDESTADDRREQ"
  _errno[90] = "EMSGSIZE"
  _errno[91] = "EPROTOTYPE"
  _errno[92] = "ENOPROTOOPT"
  _errno[93] = "EPROTONOSUPPORT"
  _errno[94] = "ESOCKTNOSUPPORT"
  _errno[95] = "EOPNOTSUPP"
  _errno[96] = "EPFNOSUPPORT"
  _errno[97] = "EAFNOSUPPORT"
  _errno[98] = "EADDRINUSE"
  _errno[99] = "EADDRNOTAVAIL"
  _errno[100] = "ENETDOWN"
  _errno[101] = "ENETUNREACH"
  _errno[102] = "ENETRESET"
  _errno[103] = "ECONNABORTED"
  _errno[104] = "ECONNRESET"
  _errno[105] = "ENOBUFS"
  _errno[106] = "EISCONN"
  _errno[107] = "ENOTCONN"
  _errno[108] = "ESHUTDOWN"
  _errno[109] = "ETOOMANYREFS"
  _errno[110] = "ETIMEDOUT"
  _errno[111] = "ECONNREFUSED"
  _errno[112] = "EHOSTDOWN"
  _errno[113] = "EHOSTUNREACH"
  _errno[114] = "EALREADY"
  _errno[115] = "EINPROGRESS"
  _errno[116] = "ESTALE"
  _errno[117] = "EUCLEAN"
  _errno[118] = "ENOTNAM"
  _errno[119] = "ENAVAIL"
  _errno[120] = "EISNAM"
  _errno[121] = "EREMOTEIO"
  _errno[122] = "EDQUOT"
  _errno[123] = "ENOMEDIUM"
  _errno[124] = "EMEDIUMTYPE"
  _errno[125] = "ECANCELED"
  _errno[126] = "ENOKEY"
  _errno[127] = "EKEYEXPIRED"
  _errno[128] = "EKEYREVOKED"
  _errno[129] = "EKEYREJECTED"
  _errno[130] = "EOWNERDEAD"
  _errno[131] = "ENOTRECOVERABLE"
  _errno[132] = "ERFKILL"
  _errno[133] = "EHWPOISON"
}

function err_num2str:string (error:long) {
  error = -error
  return (error in _errno ? _errno[error] : sprintf("0x%x", -error))
}

probe module("sunrpc").function("__rpc_execute").call {
  if (pid() == target()) {
      t = task_current()
      p = probefunc()
      serv      = @cast($task->tk_client, "struct rpc_clnt")->cl_server
      serv_name = kernel_string(serv)
      proc      = @cast(&$task->tk_msg, "struct rpc_message")->rpc_proc
      func      = @cast(proc, "struct rpc_procinfo")->p_name
      func_name = kernel_string(func)
      printf("[0x%x] %s -> %s: func: %s, server: %s, parms: %s\n", t, thread_indent(1), p, func_name, serv_name, $$parms)
      trace[t] = 1
  }
}

probe module("sunrpc").function("__rpc_execute").return {
  t = task_current()
  p = probefunc()
  if (trace[t]) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), p, $$return)
    trace[t] = 0
  }
}

probe module("sunrpc").function("xs_tcp_send_request").call {
  t = task_current()
  p = probefunc()
  if (trace[t] == 1) {
    printf("[0x%x] %s -> %s: %s\n", t, thread_indent(1), p, $$parms)
    trace[t] = 2
  }
}

probe module("sunrpc").function("xs_tcp_send_request").return {
  t = task_current()
  if (trace[t] == 2) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), err_num2str($return))
    trace[t] = 1
  }
}

probe module("sunrpc").function("*").call,
      kernel.function("*@net/ipv4/tcp*").call,
      kernel.function("*@net/core/stream.c").call,
      kernel.function("*@net/socket.c").call {
  t = task_current()
  p = probefunc()
  if (trace[t] == 2) {
    printf("[0x%x] %s -> %s: %s\n", t, thread_indent(1), p, $$parms)
  }
}

probe module("sunrpc").function("*").return,
      kernel.function("*@net/ipv4/tcp*").return,
      kernel.function("*@net/core/stream.c").return,
      kernel.function("*@net/socket.c").return {
  t = task_current()
  p = probefunc()
  if (trace[t] == 2) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), p, $$return)
  }
}

# vim: ts=2 sts=2 sw=2 et

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="11.stp"

global trace

global _tcp_state[13]
global _sock_state[5]
global _errno[134]

global _sock_sk_shutdown[2]

probe begin {
  /* from include/net/tcp_states.h */
  _tcp_state[0]  = "UNDEF"
  _tcp_state[1]  = "TCP_ESTABLISHED"
  _tcp_state[2]  = "TCP_SYN_SENT"
  _tcp_state[3]  = "TCP_SYN_RECV"
  _tcp_state[4]  = "TCP_FIN_WAIT1"
  _tcp_state[5]  = "TCP_FIN_WAIT2"
  _tcp_state[6]  = "TCP_TIME_WAIT"
  _tcp_state[7]  = "TCP_CLOSE"
  _tcp_state[8]  = "TCP_CLOSE_WAIT"
  _tcp_state[9]  = "TCP_LAST_ACK"
  _tcp_state[10] = "TCP_LISTEN"
  _tcp_state[11] = "TCP_CLOSING"
  _tcp_state[12] = "TCP_MAX_STATES"

  /* from include/linux/net.h */
  _sock_state[0] = "SS_FREE"
  _sock_state[1] = "SS_UNCONNECTED"
  _sock_state[2] = "SS_CONNECTING"
  _sock_state[3] = "SS_CONNECTED"
  _sock_state[4] = "SS_DISCONNECTING"

  /* from include/asm-generic/errno-base.h
   * and  include/asm-generic/errno.h
   */
  _errno[0] = "0"
  _errno[1] = "EPERM"
  _errno[2] = "ENOENT"
  _errno[3] = "ESRCH"
  _errno[4] = "EINTR"
  _errno[5] = "EIO"
  _errno[6] = "ENXIO"
  _errno[7] = "E2BIG"
  _errno[8] = "ENOEXEC"
  _errno[9] = "EBADF"
  _errno[10] = "ECHILD"
  _errno[11] = "EAGAIN"
  _errno[12] = "ENOMEM"
  _errno[13] = "EACCES"
  _errno[14] = "EFAULT"
  _errno[15] = "ENOTBLK"
  _errno[16] = "EBUSY"
  _errno[17] = "EEXIST"
  _errno[18] = "EXDEV"
  _errno[19] = "ENODEV"
  _errno[20] = "ENOTDIR"
  _errno[21] = "EISDIR"
  _errno[22] = "EINVAL"
  _errno[23] = "ENFILE"
  _errno[24] = "EMFILE"
  _errno[25] = "ENOTTY"
  _errno[26] = "ETXTBSY"
  _errno[27] = "EFBIG"
  _errno[28] = "ENOSPC"
  _errno[29] = "ESPIPE"
  _errno[30] = "EROFS"
  _errno[31] = "EMLINK"
  _errno[32] = "EPIPE"
  _errno[33] = "EDOM"
  _errno[34] = "ERANGE"
  _errno[35] = "EDEADLK"
  _errno[36] = "ENAMETOOLONG"
  _errno[37] = "ENOLCK"
  _errno[38] = "ENOSYS"
  _errno[39] = "ENOTEMPTY"
  _errno[40] = "ELOOP"
  _errno[41] = "UNDEF"
  _errno[42] = "ENOMSG"
  _errno[43] = "EIDRM"
  _errno[44] = "ECHRNG"
  _errno[45] = "EL2NSYNC"
  _errno[46] = "EL3HLT"
  _errno[47] = "EL3RST"
  _errno[48] = "ELNRNG"
  _errno[49] = "EUNATCH"
  _errno[50] = "ENOCSI"
  _errno[51] = "EL2HLT"
  _errno[52] = "EBADE"
  _errno[53] = "EBADR"
  _errno[54] = "EXFULL"
  _errno[55] = "ENOANO"
  _errno[56] = "EBADRQC"
  _errno[57] = "EBADSLT"
  _errno[58] = "UNDEF"
  _errno[59] = "EBFONT"
  _errno[60] = "ENOSTR"
  _errno[61] = "ENODATA"
  _errno[62] = "ETIME"
  _errno[63] = "ENOSR"
  _errno[64] = "ENONET"
  _errno[65] = "ENOPKG"
  _errno[66] = "EREMOTE"
  _errno[67] = "ENOLINK"
  _errno[68] = "EADV"
  _errno[69] = "ESRMNT"
  _errno[70] = "ECOMM"
  _errno[71] = "EPROTO"
  _errno[72] = "EMULTIHOP"
  _errno[73] = "EDOTDOT"
  _errno[74] = "EBADMSG"
  _errno[75] = "EOVERFLOW"
  _errno[76] = "ENOTUNIQ"
  _errno[77] = "EBADFD"
  _errno[78] = "EREMCHG"
  _errno[79] = "ELIBACC"
  _errno[80] = "ELIBBAD"
  _errno[81] = "ELIBSCN"
  _errno[82] = "ELIBMAX"
  _errno[83] = "ELIBEXEC"
  _errno[84] = "EILSEQ"
  _errno[85] = "ERESTART"
  _errno[86] = "ESTRPIPE"
  _errno[87] = "EUSERS"
  _errno[88] = "ENOTSOCK"
  _errno[89] = "EDESTADDRREQ"
  _errno[90] = "EMSGSIZE"
  _errno[91] = "EPROTOTYPE"
  _errno[92] = "ENOPROTOOPT"
  _errno[93] = "EPROTONOSUPPORT"
  _errno[94] = "ESOCKTNOSUPPORT"
  _errno[95] = "EOPNOTSUPP"
  _errno[96] = "EPFNOSUPPORT"
  _errno[97] = "EAFNOSUPPORT"
  _errno[98] = "EADDRINUSE"
  _errno[99] = "EADDRNOTAVAIL"
  _errno[100] = "ENETDOWN"
  _errno[101] = "ENETUNREACH"
  _errno[102] = "ENETRESET"
  _errno[103] = "ECONNABORTED"
  _errno[104] = "ECONNRESET"
  _errno[105] = "ENOBUFS"
  _errno[106] = "EISCONN"
  _errno[107] = "ENOTCONN"
  _errno[108] = "ESHUTDOWN"
  _errno[109] = "ETOOMANYREFS"
  _errno[110] = "ETIMEDOUT"
  _errno[111] = "ECONNREFUSED"
  _errno[112] = "EHOSTDOWN"
  _errno[113] = "EHOSTUNREACH"
  _errno[114] = "EALREADY"
  _errno[115] = "EINPROGRESS"
  _errno[116] = "ESTALE"
  _errno[117] = "EUCLEAN"
  _errno[118] = "ENOTNAM"
  _errno[119] = "ENAVAIL"
  _errno[120] = "EISNAM"
  _errno[121] = "EREMOTEIO"
  _errno[122] = "EDQUOT"
  _errno[123] = "ENOMEDIUM"
  _errno[124] = "EMEDIUMTYPE"
  _errno[125] = "ECANCELED"
  _errno[126] = "ENOKEY"
  _errno[127] = "EKEYEXPIRED"
  _errno[128] = "EKEYREVOKED"
  _errno[129] = "EKEYREJECTED"
  _errno[130] = "EOWNERDEAD"
  _errno[131] = "ENOTRECOVERABLE"
  _errno[132] = "ERFKILL"
  _errno[133] = "EHWPOISON"
}

function err_num2str:string (error:long) {
  error = -error
  return (error in _errno ? _errno[error] : sprintf("0x%x", -error))
}

function sk_state_num2str:string (state:long) {
  return (state in _tcp_state ? _tcp_state[state] : sprintf("0x%x", state))
}

function sock_state_num2str:string (state:long)
{
  return (state in _sock_state ? _sock_state[state] : sprintf("0x%x", state))
}

function sk_shutdown_num2str:string (flags:long)
{
  /* from include/net/sock.h */
  RCV_SHUTDOWN  = 1
  SEND_SHUTDOWN = 2

  retvalue = ""
  if (flags & SEND_SHUTDOWN)
    _sock_sk_shutdown["SEND_SHUTDOWN"] = 1

  if (flags & RCV_SHUTDOWN)
    _sock_sk_shutdown["RCV_SHUTDOWN"] = 1

  foreach (key in _sock_sk_shutdown) {
    sep = retvalue == "" ? "" : "|"
    retvalue = sprintf("%s%s%s", retvalue, sep, key)
  }

  delete _sock_sk_shutdown
  return retvalue == "" ? "0" : retvalue
}

function sk2str:string (sk:long)
{
  sk_state    = sk_state_num2str(@cast(sk, "struct sock")->__sk_common->skc_state)
  sk_shutdown = sk_shutdown_num2str(@cast(sk, "struct sock")->sk_shutdown)
  sk_err      = err_num2str(-(@cast(sk, "struct sock")->sk_err))
  return sprintf("sk=0x%x, sk_state: %s, sk_err: %s, sk_shutdown: %s", sk, sk_state, sk_err, sk_shutdown)
}

function sock2str:string (sock:long)
{
  sock_state = @cast(sock, "struct socket")->state
  sock_sk    = @cast(sock, "struct socket")->sk
  return sprintf("sock=0x%x, state: %s, %s", sock, sock_state_num2str(sock_state), sk2str(sock_sk))
}

probe module("sunrpc").function("__rpc_execute").call {
  if (pid() == target()) {
      t = task_current()
      p = probefunc()
      serv      = @cast($task->tk_client, "struct rpc_clnt")->cl_server
      serv_name = kernel_string(serv)
      proc      = @cast(&$task->tk_msg, "struct rpc_message")->rpc_proc
      func      = @cast(proc, "struct rpc_procinfo")->p_name
      func_name = kernel_string(func)
      printf("[0x%x] %s -> %s: func: %s, server: %s, parms: %s\n", t, thread_indent(1), p, func_name, serv_name, $$parms)
      trace[t] = 1
  }
}

probe module("sunrpc").function("__rpc_execute").return {
  t = task_current()
  p = probefunc()
  if (trace[t]) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), p, $$return)
    trace[t] = 0
  }
}

probe module("sunrpc").function("xs_tcp_send_request").call {
  t = task_current()
  p = probefunc()
  if (trace[t] == 1) {
    printf("[0x%x] %s -> %s: %s\n", t, thread_indent(1), p, $$parms)
    trace[t] = 2
  }
}

probe module("sunrpc").function("xs_tcp_send_request").return {
  t = task_current()
  if (trace[t] == 2) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), err_num2str($return))
    trace[t] = 1
  }
}

probe kernel.function("tcp_sendmsg").call {
  t = task_current()
  if (trace[t] == 2) {
    printf("[0x%x] %s -> %s: sock: %s\n", t, thread_indent(1), probefunc(), sock2str($sock))
  }
}

probe kernel.function("tcp_sendmsg").return {
  t = task_current()
  if (trace[t] == 2) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), err_num2str($return))
  }
}

probe kernel.function("sk_stream_wait_connect").call {
  t = task_current()
  if (trace[t] == 2) {
    printf("[0x%x] %s -> %s: sk: %s, time_out: %ld\n", t, thread_indent(1), probefunc(), sk2str($sk), kernel_long($timeo_p))
  }
}

probe kernel.function("sk_stream_wait_connect").return {
  t = task_current()
  if (trace[t] == 2) {
    printf("[0x%x] %s <- %s: %s\n", t, thread_indent(-1), probefunc(), err_num2str($return))
  }
}

#  vim: ts=2 sts=2 sw=2 et

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="14.stp"

global trace
global sk_trace
global task_trace

global _tcp_state[13]
global _sock_state[5]
global _errno[134]

global _task_tk_runstate[3]
global _sock_sk_shutdown[2]

probe begin {
  /* from include/net/tcp_states.h */
  _tcp_state[0]  = "UNDEF"
  _tcp_state[1]  = "TCP_ESTABLISHED"
  _tcp_state[2]  = "TCP_SYN_SENT"
  _tcp_state[3]  = "TCP_SYN_RECV"
  _tcp_state[4]  = "TCP_FIN_WAIT1"
  _tcp_state[5]  = "TCP_FIN_WAIT2"
  _tcp_state[6]  = "TCP_TIME_WAIT"
  _tcp_state[7]  = "TCP_CLOSE"
  _tcp_state[8]  = "TCP_CLOSE_WAIT"
  _tcp_state[9]  = "TCP_LAST_ACK"
  _tcp_state[10] = "TCP_LISTEN"
  _tcp_state[11] = "TCP_CLOSING"
  _tcp_state[12] = "TCP_MAX_STATES"

  /* from include/linux/net.h */
  _sock_state[0] = "SS_FREE"
  _sock_state[1] = "SS_UNCONNECTED"
  _sock_state[2] = "SS_CONNECTING"
  _sock_state[3] = "SS_CONNECTED"
  _sock_state[4] = "SS_DISCONNECTING"

  _errno[0] = "0"
  _errno[1] = "EPERM"
  _errno[2] = "ENOENT"
  _errno[3] = "ESRCH"
  _errno[4] = "EINTR"
  _errno[5] = "EIO"
  _errno[6] = "ENXIO"
  _errno[7] = "E2BIG"
  _errno[8] = "ENOEXEC"
  _errno[9] = "EBADF"
  _errno[10] = "ECHILD"
  _errno[11] = "EAGAIN"
  _errno[12] = "ENOMEM"
  _errno[13] = "EACCES"
  _errno[14] = "EFAULT"
  _errno[15] = "ENOTBLK"
  _errno[16] = "EBUSY"
  _errno[17] = "EEXIST"
  _errno[18] = "EXDEV"
  _errno[19] = "ENODEV"
  _errno[20] = "ENOTDIR"
  _errno[21] = "EISDIR"
  _errno[22] = "EINVAL"
  _errno[23] = "ENFILE"
  _errno[24] = "EMFILE"
  _errno[25] = "ENOTTY"
  _errno[26] = "ETXTBSY"
  _errno[27] = "EFBIG"
  _errno[28] = "ENOSPC"
  _errno[29] = "ESPIPE"
  _errno[30] = "EROFS"
  _errno[31] = "EMLINK"
  _errno[32] = "EPIPE"
  _errno[33] = "EDOM"
  _errno[34] = "ERANGE"
  _errno[35] = "EDEADLK"
  _errno[36] = "ENAMETOOLONG"
  _errno[37] = "ENOLCK"
  _errno[38] = "ENOSYS"
  _errno[39] = "ENOTEMPTY"
  _errno[40] = "ELOOP"
  _errno[41] = "UNDEF"
  _errno[42] = "ENOMSG"
  _errno[43] = "EIDRM"
  _errno[44] = "ECHRNG"
  _errno[45] = "EL2NSYNC"
  _errno[46] = "EL3HLT"
  _errno[47] = "EL3RST"
  _errno[48] = "ELNRNG"
  _errno[49] = "EUNATCH"
  _errno[50] = "ENOCSI"
  _errno[51] = "EL2HLT"
  _errno[52] = "EBADE"
  _errno[53] = "EBADR"
  _errno[54] = "EXFULL"
  _errno[55] = "ENOANO"
  _errno[56] = "EBADRQC"
  _errno[57] = "EBADSLT"
  _errno[58] = "UNDEF"
  _errno[59] = "EBFONT"
  _errno[60] = "ENOSTR"
  _errno[61] = "ENODATA"
  _errno[62] = "ETIME"
  _errno[63] = "ENOSR"
  _errno[64] = "ENONET"
  _errno[65] = "ENOPKG"
  _errno[66] = "EREMOTE"
  _errno[67] = "ENOLINK"
  _errno[68] = "EADV"
  _errno[69] = "ESRMNT"
  _errno[70] = "ECOMM"
  _errno[71] = "EPROTO"
  _errno[72] = "EMULTIHOP"
  _errno[73] = "EDOTDOT"
  _errno[74] = "EBADMSG"
  _errno[75] = "EOVERFLOW"
  _errno[76] = "ENOTUNIQ"
  _errno[77] = "EBADFD"
  _errno[78] = "EREMCHG"
  _errno[79] = "ELIBACC"
  _errno[80] = "ELIBBAD"
  _errno[81] = "ELIBSCN"
  _errno[82] = "ELIBMAX"
  _errno[83] = "ELIBEXEC"
  _errno[84] = "EILSEQ"
  _errno[85] = "ERESTART"
  _errno[86] = "ESTRPIPE"
  _errno[87] = "EUSERS"
  _errno[88] = "ENOTSOCK"
  _errno[89] = "EDESTADDRREQ"
  _errno[90] = "EMSGSIZE"
  _errno[91] = "EPROTOTYPE"
  _errno[92] = "ENOPROTOOPT"
  _errno[93] = "EPROTONOSUPPORT"
  _errno[94] = "ESOCKTNOSUPPORT"
  _errno[95] = "EOPNOTSUPP"
  _errno[96] = "EPFNOSUPPORT"
  _errno[97] = "EAFNOSUPPORT"
  _errno[98] = "EADDRINUSE"
  _errno[99] = "EADDRNOTAVAIL"
  _errno[100] = "ENETDOWN"
  _errno[101] = "ENETUNREACH"
  _errno[102] = "ENETRESET"
  _errno[103] = "ECONNABORTED"
  _errno[104] = "ECONNRESET"
  _errno[105] = "ENOBUFS"
  _errno[106] = "EISCONN"
  _errno[107] = "ENOTCONN"
  _errno[108] = "ESHUTDOWN"
  _errno[109] = "ETOOMANYREFS"
  _errno[110] = "ETIMEDOUT"
  _errno[111] = "ECONNREFUSED"
  _errno[112] = "EHOSTDOWN"
  _errno[113] = "EHOSTUNREACH"
  _errno[114] = "EALREADY"
  _errno[115] = "EINPROGRESS"
  _errno[116] = "ESTALE"
  _errno[117] = "EUCLEAN"
  _errno[118] = "ENOTNAM"
  _errno[119] = "ENAVAIL"
  _errno[120] = "EISNAM"
  _errno[121] = "EREMOTEIO"
  _errno[122] = "EDQUOT"
  _errno[123] = "ENOMEDIUM"
  _errno[124] = "EMEDIUMTYPE"
  _errno[125] = "ECANCELED"
  _errno[126] = "ENOKEY"
  _errno[127] = "EKEYEXPIRED"
  _errno[128] = "EKEYREVOKED"
  _errno[129] = "EKEYREJECTED"
  _errno[130] = "EOWNERDEAD"
  _errno[131] = "ENOTRECOVERABLE"
  _errno[132] = "ERFKILL"
  _errno[133] = "EHWPOISON"
}

function err_num2str:string (error:long) {
  error = -error
  return (error in _errno ? _errno[error] : sprintf("0x%x", -error))
}

function sk_state_num2str:string (state:long) {
  return (state in _tcp_state ? _tcp_state[state] : sprintf("0x%x", state))
}

function sock_state_num2str:string (state:long)
{
  return (state in _sock_state ? _sock_state[state] : sprintf("0x%x", state))
}

function sk_shutdown_num2str:string (flags:long)
{
  /* from include/net/sock.h */
  RCV_SHUTDOWN  = 1
  SEND_SHUTDOWN = 2

  retvalue = ""
  if (flags & SEND_SHUTDOWN)
    _sock_sk_shutdown["SEND_SHUTDOWN"] = 1

  if (flags & RCV_SHUTDOWN)
    _sock_sk_shutdown["RCV_SHUTDOWN"] = 1

  foreach (key in _sock_sk_shutdown) {
    sep = retvalue == "" ? "" : "|"
    retvalue = sprintf("%s%s%s", retvalue, sep, key)
  }

  delete _sock_sk_shutdown
  return retvalue == "" ? "0" : retvalue
}

function sk2str:string (sk:long)
{
  sk_state    = sk_state_num2str(@cast(sk, "struct sock")->__sk_common->skc_state)
  sk_shutdown = sk_shutdown_num2str(@cast(sk, "struct sock")->sk_shutdown)
  sk_err      = err_num2str(-(@cast(sk, "struct sock")->sk_err))
  return sprintf("sk=0x%x, sk_state: %s, sk_err: %s, sk_shutdown: %s", sk, sk_state, sk_err, sk_shutdown)
}

function sock2str:string (sock:long)
{
  sock_state = @cast(sock, "struct socket")->state
  sock_sk    = @cast(sock, "struct socket")->sk
  return sprintf("sock=0x%x, state: %s, %s", sock, sock_state_num2str(sock_state), sk2str(sock_sk))
}

function task_runstate_num2str:string (word:long)
{
  /* from include/linux/runrpc/sched.h but watch out, needs translation from
   * the values there for use in '&' as they use `test_bit'
   */

  RPC_TASK_RUNNING = 1
  RPC_TASK_QUEUED  = 2
  RPC_TASK_ACTIVE  = 4

  retvalue = ""
  if (word & RPC_TASK_RUNNING)
    _task_tk_runstate["RPC_TASK_RUNNING"] = 1
  if (word & RPC_TASK_QUEUED)
    _task_tk_runstate["RPC_TASK_QUEUED"] = 1
  if (word & RPC_TASK_ACTIVE)
    _task_tk_runstate["RPC_TASK_ACTIVE"] = 1

  foreach (key in _task_tk_runstate) {
    sep = retvalue == "" ? "" : "|"
    retvalue = sprintf("%s%s%s", retvalue, sep, key)
  }

  delete _task_tk_runstate
  retvalue = retvalue == "" ? "0" : retvalue
  return sprintf("tk_runstate: %s", retvalue)
}

function task2str:string (task:long)
{
  tk_runstate = @cast(task, "struct rpc_task", "kernel<linux/sunrpc/sched.h>")->tk_runstate
  tk_status   = @cast(task, "struct rpc_task", "kernel<linux/sunrpc/sched.h>")->tk_status
  return sprintf("tk_status: %s, %s", err_num2str(tk_status), task_runstate_num2str(tk_runstate))
}

probe module("sunrpc").function("__rpc_execute").call {
  if (pid() == target()) {
      t = task_current()
      p = probefunc()

      /* pull the server name */
      serv      = @cast($task->tk_client, "struct rpc_clnt")->cl_server
      serv_name = kernel_string(serv)

      proc      = @cast(&$task->tk_msg, "struct rpc_message")->rpc_proc
      func      = @cast(proc, "struct rpc_procinfo")->p_name
      func_name = kernel_string(func)

      printf("%d [0x%x] %s -> %s: func: %s, server: %s, task: %s, parms: %s\n", gettimeofday_ns(), t, thread_indent(1), p, func_name, serv_name, task2str($task), $$parms)
      trace[t] = 1
      task_trace[$task] = 1
  }
}

probe module("sunrpc").function("__rpc_execute").return {
  t = task_current()
  p = probefunc()
  if (trace[t]) {
    printf("%d [0x%x] %s <- %s: %s\n", gettimeofday_ns(), t, thread_indent(-1), p, $$return)
    trace[t] = 0
    delete task_trace
  }
}

probe module("sunrpc").function("call_*").call {
  t = task_current()
  p = probefunc()
  if (trace[t]) {
    printf("%d [0x%x] %s -> %s: task: %s, parms: %s\n", gettimeofday_ns(), t, thread_indent(1), p, task2str($task), $$parms)
  }
}

probe module("sunrpc").function("call_*").return {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x] %s <- %s: %s\n", gettimeofday_ns(), t, thread_indent(-1), probefunc(), $$return)
  }
}

probe module("sunrpc").function("xs_tcp_send_request").call {
  t = task_current()
  p = probefunc()
  if (trace[t]) {
    rq_xprt     = @cast($task->tk_rqstp, "struct rpc_rqst")->rq_xprt
    sock        = @cast(rq_xprt - (& @cast(0, "struct sock_xprt")->xprt), "struct sock_xprt")->sock
    sk          = @cast(sock, "struct socket")->sk
    printf("%d [0x%x] %s -> %s: sock: %s, task: %s, parms: %s\n", gettimeofday_ns(), t, thread_indent(1), p, sock2str(sock), task2str($task), $$parms)
    sk_trace[sk] = 1
  }
}

probe module("sunrpc").function("xs_tcp_send_request").return {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x] %s <- %s: %s\n", gettimeofday_ns(), t, thread_indent(-1), probefunc(), err_num2str($return))
  }
}

probe module("sunrpc").function("xs_connect").call {
  t = task_current()
  if (trace[t]) {
    rq_xprt     = @cast($task->tk_rqstp, "struct rpc_rqst")->rq_xprt
    sock        = @cast(rq_xprt - (& @cast(0, "struct sock_xprt")->xprt), "struct sock_xprt")->sock
    printf("%d [0x%x] %s -> %s: sock: %s, task: %s, parms: %s\n", gettimeofday_ns(), t, thread_indent(1), probefunc(), sock2str(sock), task2str($task), $$parms)
  }
}

probe module("sunrpc").function("xs_connect").return {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x] %s <- %s\n", gettimeofday_ns(), t, thread_indent(-1), probefunc())
  }
}

probe module("sunrpc").function("rpc_wait_bit_killable").call {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x] %s -> %s: parms: %s\n", gettimeofday_ns(), t, thread_indent(1), probefunc(), $$parms)
  }
}

probe module("sunrpc").function("rpc_wait_bit_killable").return {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x] %s <- %s\n", gettimeofday_ns(), t, thread_indent(-1), probefunc())
  }
}

probe kernel.function("sk_stream_wait_connect").call {
  t = task_current()
  p = probefunc()
  if (trace[t]) {
    printf("%d [0x%x] %s -> %s: sk: %s, time_out: %d, parms: %s\n", gettimeofday_ns(), t, thread_indent(1), p, sk2str($sk), kernel_long($timeo_p), $$parms)
  }
}

probe kernel.function("sk_stream_wait_connect").return {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x] %s <- %s: %s\n", gettimeofday_ns(), t, thread_indent(-1), probefunc(), err_num2str($return))
  }
}

probe kernel.function("out_of_line_wait_on_bit").call {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x] %s -> %s: word: %s, parms: %s\n", gettimeofday_ns(), t, thread_indent(1), probefunc(), task_runstate_num2str(kernel_long($word)), $$parms)
  }
}

probe kernel.function("out_of_line_wait_on_bit").return {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x] %s <- %s\n", gettimeofday_ns(), t, thread_indent(-1), probefunc())
  }
}

probe module("sunrpc").function("rpc_make_runnable").call {
  t = task_current()
  if (task_trace[$task]) {
    printf("%d [0x%x] %s -> %s: task: %s, parms: %s\n", gettimeofday_ns(), t, execname(), probefunc(), task2str($task), $$parms)
    print_backtrace()
  }
}

probe kernel.function("tcp_set_state").call {
  if (sk_trace[$sk]) {
    t = task_current()
    printf("%d [0x%x] %s -> %s: sk: %s, NEW sk_state: %s\n",
            gettimeofday_ns(), t, execname(), probefunc(), sk2str($sk), sk_state_num2str($state))
    print_backtrace()
  }
}

--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="rpciod.stp"

global trace

global _tcp_state[13]
global _sock_state[5]
global _errno[134]

global _sock_sk_shutdown[2]

probe begin {
  /* from include/net/tcp_states.h */
  _tcp_state[0]  = "UNDEF"
  _tcp_state[1]  = "TCP_ESTABLISHED"
  _tcp_state[2]  = "TCP_SYN_SENT"
  _tcp_state[3]  = "TCP_SYN_RECV"
  _tcp_state[4]  = "TCP_FIN_WAIT1"
  _tcp_state[5]  = "TCP_FIN_WAIT2"
  _tcp_state[6]  = "TCP_TIME_WAIT"
  _tcp_state[7]  = "TCP_CLOSE"
  _tcp_state[8]  = "TCP_CLOSE_WAIT"
  _tcp_state[9]  = "TCP_LAST_ACK"
  _tcp_state[10] = "TCP_LISTEN"
  _tcp_state[11] = "TCP_CLOSING"
  _tcp_state[12] = "TCP_MAX_STATES"

  /* from include/linux/net.h */
  _sock_state[0] = "SS_FREE"
  _sock_state[1] = "SS_UNCONNECTED"
  _sock_state[2] = "SS_CONNECTING"
  _sock_state[3] = "SS_CONNECTED"
  _sock_state[4] = "SS_DISCONNECTING"

  _errno[0] = "0"
  _errno[1] = "EPERM"
  _errno[2] = "ENOENT"
  _errno[3] = "ESRCH"
  _errno[4] = "EINTR"
  _errno[5] = "EIO"
  _errno[6] = "ENXIO"
  _errno[7] = "E2BIG"
  _errno[8] = "ENOEXEC"
  _errno[9] = "EBADF"
  _errno[10] = "ECHILD"
  _errno[11] = "EAGAIN"
  _errno[12] = "ENOMEM"
  _errno[13] = "EACCES"
  _errno[14] = "EFAULT"
  _errno[15] = "ENOTBLK"
  _errno[16] = "EBUSY"
  _errno[17] = "EEXIST"
  _errno[18] = "EXDEV"
  _errno[19] = "ENODEV"
  _errno[20] = "ENOTDIR"
  _errno[21] = "EISDIR"
  _errno[22] = "EINVAL"
  _errno[23] = "ENFILE"
  _errno[24] = "EMFILE"
  _errno[25] = "ENOTTY"
  _errno[26] = "ETXTBSY"
  _errno[27] = "EFBIG"
  _errno[28] = "ENOSPC"
  _errno[29] = "ESPIPE"
  _errno[30] = "EROFS"
  _errno[31] = "EMLINK"
  _errno[32] = "EPIPE"
  _errno[33] = "EDOM"
  _errno[34] = "ERANGE"
  _errno[35] = "EDEADLK"
  _errno[36] = "ENAMETOOLONG"
  _errno[37] = "ENOLCK"
  _errno[38] = "ENOSYS"
  _errno[39] = "ENOTEMPTY"
  _errno[40] = "ELOOP"
  _errno[41] = "UNDEF"
  _errno[42] = "ENOMSG"
  _errno[43] = "EIDRM"
  _errno[44] = "ECHRNG"
  _errno[45] = "EL2NSYNC"
  _errno[46] = "EL3HLT"
  _errno[47] = "EL3RST"
  _errno[48] = "ELNRNG"
  _errno[49] = "EUNATCH"
  _errno[50] = "ENOCSI"
  _errno[51] = "EL2HLT"
  _errno[52] = "EBADE"
  _errno[53] = "EBADR"
  _errno[54] = "EXFULL"
  _errno[55] = "ENOANO"
  _errno[56] = "EBADRQC"
  _errno[57] = "EBADSLT"
  _errno[58] = "UNDEF"
  _errno[59] = "EBFONT"
  _errno[60] = "ENOSTR"
  _errno[61] = "ENODATA"
  _errno[62] = "ETIME"
  _errno[63] = "ENOSR"
  _errno[64] = "ENONET"
  _errno[65] = "ENOPKG"
  _errno[66] = "EREMOTE"
  _errno[67] = "ENOLINK"
  _errno[68] = "EADV"
  _errno[69] = "ESRMNT"
  _errno[70] = "ECOMM"
  _errno[71] = "EPROTO"
  _errno[72] = "EMULTIHOP"
  _errno[73] = "EDOTDOT"
  _errno[74] = "EBADMSG"
  _errno[75] = "EOVERFLOW"
  _errno[76] = "ENOTUNIQ"
  _errno[77] = "EBADFD"
  _errno[78] = "EREMCHG"
  _errno[79] = "ELIBACC"
  _errno[80] = "ELIBBAD"
  _errno[81] = "ELIBSCN"
  _errno[82] = "ELIBMAX"
  _errno[83] = "ELIBEXEC"
  _errno[84] = "EILSEQ"
  _errno[85] = "ERESTART"
  _errno[86] = "ESTRPIPE"
  _errno[87] = "EUSERS"
  _errno[88] = "ENOTSOCK"
  _errno[89] = "EDESTADDRREQ"
  _errno[90] = "EMSGSIZE"
  _errno[91] = "EPROTOTYPE"
  _errno[92] = "ENOPROTOOPT"
  _errno[93] = "EPROTONOSUPPORT"
  _errno[94] = "ESOCKTNOSUPPORT"
  _errno[95] = "EOPNOTSUPP"
  _errno[96] = "EPFNOSUPPORT"
  _errno[97] = "EAFNOSUPPORT"
  _errno[98] = "EADDRINUSE"
  _errno[99] = "EADDRNOTAVAIL"
  _errno[100] = "ENETDOWN"
  _errno[101] = "ENETUNREACH"
  _errno[102] = "ENETRESET"
  _errno[103] = "ECONNABORTED"
  _errno[104] = "ECONNRESET"
  _errno[105] = "ENOBUFS"
  _errno[106] = "EISCONN"
  _errno[107] = "ENOTCONN"
  _errno[108] = "ESHUTDOWN"
  _errno[109] = "ETOOMANYREFS"
  _errno[110] = "ETIMEDOUT"
  _errno[111] = "ECONNREFUSED"
  _errno[112] = "EHOSTDOWN"
  _errno[113] = "EHOSTUNREACH"
  _errno[114] = "EALREADY"
  _errno[115] = "EINPROGRESS"
  _errno[116] = "ESTALE"
  _errno[117] = "EUCLEAN"
  _errno[118] = "ENOTNAM"
  _errno[119] = "ENAVAIL"
  _errno[120] = "EISNAM"
  _errno[121] = "EREMOTEIO"
  _errno[122] = "EDQUOT"
  _errno[123] = "ENOMEDIUM"
  _errno[124] = "EMEDIUMTYPE"
  _errno[125] = "ECANCELED"
  _errno[126] = "ENOKEY"
  _errno[127] = "EKEYEXPIRED"
  _errno[128] = "EKEYREVOKED"
  _errno[129] = "EKEYREJECTED"
  _errno[130] = "EOWNERDEAD"
  _errno[131] = "ENOTRECOVERABLE"
  _errno[132] = "ERFKILL"
  _errno[133] = "EHWPOISON"
}

/**** Helpers ****/

function err_num2str:string (error:long) {
  error = -error
  return (error in _errno ? _errno[error] : sprintf("0x%x", -error))
}

function sk_state_num2str:string (state:long) {
  return (state in _tcp_state ? _tcp_state[state] : sprintf("0x%x", state))
}

function sock_state_num2str:string (state:long)
{
  return (state in _sock_state ? _sock_state[state] : sprintf("0x%x", state))
}

function sk_shutdown_num2str:string (flags:long)
{
  /* from include/net/sock.h */
  RCV_SHUTDOWN  = 1
  SEND_SHUTDOWN = 2

  retvalue = ""
  if (flags & SEND_SHUTDOWN)
    _sock_sk_shutdown["SEND_SHUTDOWN"] = 1

  if (flags & RCV_SHUTDOWN)
    _sock_sk_shutdown["RCV_SHUTDOWN"] = 1

  foreach (key in _sock_sk_shutdown) {
    sep = retvalue == "" ? "" : "|"
    retvalue = sprintf("%s%s%s", retvalue, sep, key)
  }

  delete _sock_sk_shutdown
  return retvalue == "" ? "0" : retvalue
}

function sk2str:string (sk:long)
{
  sk_state    = sk_state_num2str(@cast(sk, "struct sock")->__sk_common->skc_state)
  sk_shutdown = sk_shutdown_num2str(@cast(sk, "struct sock")->sk_shutdown)
  sk_err      = err_num2str(-(@cast(sk, "struct sock")->sk_err))
  return sprintf("sk=0x%x, sk_state: %s, sk_err: %s, sk_shutdown: %s", sk, sk_state, sk_err, sk_shutdown)
}

function sock2str:string (sock:long)
{
  sock_state = @cast(sock, "struct socket")->state
  sock_sk    = @cast(sock, "struct socket")->sk
  return sprintf("sock=0x%x, state: %s, %s", sock, sock_state_num2str(sock_state), sk2str(sock_sk))
}

/**** Actual Probes Below ****/

probe module("sunrpc").function("xs_tcp_setup_socket").call {
  if (isinstr(execname(), "rpciod")) {
    t = task_current()
    trace[t] = 1
    printf("%d [0x%x]: %s -> %s: parms: %s\n", gettimeofday_ns(), t, thread_indent(1), probefunc(), $$parms)
  }
}

probe module("sunrpc").function("xs_tcp_setup_socket").return {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x]: %s <- %s: %s\n", gettimeofday_ns(), t, thread_indent(-1), probefunc(), $$return)
  }
  trace[t] = 0
}

probe kernel.function("kernel_connect").call {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x]: %s -> %s: sock: %s, parms: %s\n", gettimeofday_ns(), t, thread_indent(1), probefunc(), sock2str($sock), $$parms)
  }
}

probe kernel.function("kernel_connect").return {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x]: %s <- %s: %s\n", gettimeofday_ns(), t, thread_indent(-1), probefunc(), err_num2str($return))
  }
}

probe module("sunrpc").function("*").call,
      kernel.function("*@net/socket.c").call {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x]: %s -> %s: parms: %s\n", gettimeofday_ns(), t, thread_indent(1), probefunc(), $$parms)
  }
}

probe module("sunrpc").function("*").return,
      kernel.function("*@net/socket.c").return {
  t = task_current()
  if (trace[t]) {
    printf("%d [0x%x]: %s <- %s: %s\n", gettimeofday_ns(), t, thread_indent(-1), probefunc(), $$return)
  }
}

--oyUTqETQ0mS9luUI--
